!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Program convert_mdcint

! ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    Implicit None
    Character  :: datex*10, timex*8
    character(50) :: mdcint_filename, mdcint_output_filename, argv
    integer :: nkr, nmo, mdcint_unit = 10, file_output_unit = 11
    integer :: i, i0, inz, nz, ikr, jkr, stat, mdcint_idx, split_num
    integer, allocatable :: indk(:), indl(:), kr(:)
    double precision, allocatable  :: rklr(:), rkli(:)
    logical :: realonly, exists, combine = .false., split = .false.

    call get_command_argument(1, argv)
    if (trim(argv) == "--combine") then
        print *, "Combine all MDCINT files into one file (--combine option is detected)"
        combine = .true.
    else if (trim(argv) == "--split") then
        print *, "Split MDCINT files into multiple files (--split option is detected)"
        split = .true.
    end if

    if (split) then
        call get_command_argument(2, argv)
        read (argv, *) split_num
        if (split_num <= 0) then
            print *, "Error: split_num <= 0"
            call exit(1)
        end if
    end if

    inquire (file="MDCINT", exist=exists)
    if (.not. exists) then
        print *, "Error: MDCINT file does not exist"
        call exit(1)
    end if
    open (mdcint_unit, file="MDCINT", form="unformatted", status="old")
    read (mdcint_unit) datex, timex, nkr
    rewind (mdcint_unit)
    nmo = 2*nkr
    allocate (kr(-nkr:nkr))
    kr(:) = 0
    read (mdcint_unit) datex, timex, nkr, (kr(i0), kr(-1*i0), i0=1, nkr)
    allocate (indk(nmo**2))
    allocate (indl(nmo**2))
    allocate (rklr(nmo**2))
    allocate (rkli(nmo**2))
    realonly = is_realonly(mdcint_unit)
    close(mdcint_unit)

    if (split) then
        call split_mdcint
    else
        call dump_formatted_mdcint
    endif
    deallocate (kr)
    deallocate (indk)
    deallocate (indl)
    deallocate (rklr)
    deallocate (rkli)

    print *, "End program normally"
contains

    logical function is_realonly(unit_num)
        implicit none
        integer, intent(in) :: unit_num
        is_realonly = .false.
        rewind (unit_num)
        read (unit_num)  ! Skip the first line
        read (unit_num, iostat=stat) ikr, jkr, nz, (indk(inz), indl(inz), inz=1, nz), (rklr(inz), rkli(inz), inz=1, nz)
        if (stat /= 0) then
            is_realonly = .true.
        else
            is_realonly = .false.
        end if
        print *, "realonly = ", realonly
    end function is_realonly

    subroutine dump_formatted_mdcint
        implicit none
        if (combine) then
            open (file_output_unit, file="formatted_MDCINT", form="formatted", status="replace")
            write (file_output_unit, *) datex, timex, nkr, (kr(i0), kr(-1*i0), i0=1, nkr)
        end if
        mdcint_idx = 0
        datex = ""
        timex = ""
        nkr = 0
        do
            call get_filename(mdcint_idx, mdcint_filename, mdcint_output_filename)
            inquire (file=mdcint_filename, exist=exists)
            if (.not. exists) then
                exit
            end if
            open (mdcint_unit, file=trim(mdcint_filename), form="unformatted", status="old")
            rewind (mdcint_unit)
            read (mdcint_unit) datex, timex, nkr, (kr(i0), kr(-1*i0), i0=1, nkr)
            if (.not. combine) then
                open (file_output_unit, file=trim(mdcint_output_filename), form="formatted", status="replace")
                write (file_output_unit, *) datex, timex, nkr, (kr(i0), kr(-1*i0), i0=1, nkr)
            end if
            do
                if (realonly) then
                    read (mdcint_unit, iostat=stat) ikr, jkr, nz, (indk(inz), indl(inz), inz=1, nz), &
                    (rklr(inz), inz=1, nz)
                else
                    read (mdcint_unit, iostat=stat) ikr, jkr, nz, (indk(inz), indl(inz), inz=1, nz), &
                    (rklr(inz), rkli(inz), inz=1, nz)
                end if
                if (ikr == 0) then
                    exit
                end if
                if (stat < 0) then
                    print *, "End of file: ", trim(mdcint_filename)
                    exit
                else if (stat > 0) then
                    print *, "Error while reading file. iostat = ", stat
                    call exit(stat)
                end if
                if (realonly) then
                    do i = 1, nz
                        write (file_output_unit, '(4I6, E20.7)') ikr, jkr, indk(i), indl(i), rklr(i)
                    end do
                else
                    do i = 1, nz
                        write (file_output_unit, '(4I6, 2E20.7)') ikr, jkr, indk(i), indl(i), rklr(i), rkli(i)
                    end do
                end if
            end do
            close (mdcint_unit)
            if (.not. combine) close (file_output_unit)
            mdcint_idx = mdcint_idx + 1
        end do

        if (combine) close (file_output_unit)

    end subroutine dump_formatted_mdcint

    subroutine split_mdcint
        implicit none
        integer, allocatable :: mdcint_files_unit(:)
        integer, parameter :: start_unit = 21
        integer :: write_file_idx, cnt
        mdcint_idx = 0
        cnt = 0
        write_file_idx = 0
        datex = ""
        timex = ""
        nkr = 0
        allocate (mdcint_files_unit(split_num))
        ! mkdir
        call system("mkdir -p split")
        do i = 0, split_num-1
            mdcint_files_unit(i+1) = start_unit + i
            call get_filename(i, mdcint_filename, mdcint_output_filename)
            ! Open split files into split directory
            open (mdcint_files_unit(i+1), file="split/"//trim(mdcint_filename), form="unformatted", status="replace")
        end do
        do
            call get_filename(mdcint_idx, mdcint_filename, mdcint_output_filename)
            inquire (file=mdcint_filename, exist=exists)
            if (.not. exists) then
                exit
            end if
            open (mdcint_unit, file=trim(mdcint_filename), form="unformatted", status="old")
            rewind (mdcint_unit)
            read (mdcint_unit) datex, timex, nkr, (kr(i0), kr(-1*i0), i0=1, nkr)
            do i = 1, split_num
                write (mdcint_files_unit(i)) datex, timex, nkr, (kr(i0), kr(-1*i0), i0=1, nkr)
            end do

            do
                if (realonly) then
                    read (mdcint_unit, iostat=stat) ikr, jkr, nz, (indk(inz), indl(inz), inz=1, nz), &
                    (rklr(inz), inz=1, nz)
                else
                    read (mdcint_unit, iostat=stat) ikr, jkr, nz, (indk(inz), indl(inz), inz=1, nz), &
                    (rklr(inz), rkli(inz), inz=1, nz)
                end if
                if (ikr == 0) then
                    print *, "End of file: ", trim(mdcint_filename)
                    exit
                end if
                write_file_idx = mod(cnt, split_num)
                if (realonly) then
                    write(mdcint_files_unit(write_file_idx+1)) ikr, jkr, nz, (indk(inz), indl(inz), inz=1, nz), &
                    (rklr(inz), inz=1, nz)
                else
                    write(mdcint_files_unit(write_file_idx+1)) ikr, jkr, nz, (indk(inz), indl(inz), inz=1, nz), &
                    (rklr(inz), rkli(inz), inz=1, nz)
                end if
                cnt = cnt + 1
            end do

            close (mdcint_unit)
            mdcint_idx = mdcint_idx + 1
        end do

        do i = 1, split_num
            close (mdcint_files_unit(i))
        end do

    end subroutine split_mdcint

    subroutine get_filename(idx, filename, output_filename)
        ! Get the filename of the MDCINT file
        ! idx = 0: filename = "MDCINT", output_filename = "formatted_MDCINT"
        ! idx > 0: filename = "MDCIN"//trim(adjustl(padding_x))//trim(adjustl(chr_idx)), output_filename = "formatted_MDCINT"//trim(adjustl(chr_idx))
        ! (e.g.) idx = 1: filename = "MDCINXXXX1", output_filename = "formatted_MDCINT1"
        !  idx = 100: filename = "MDCINXX100", output_filename = "formatted_MDCINT100"
        integer, intent(in) :: idx
        character(len=*), intent(out) :: filename, output_filename
        character(50) :: chr_idx, padding_x
        if (idx < 0) then
            print *, "Error: idx < 0"
            call exit(1)
        else if (idx == 0) then
            filename = "MDCINT"
            output_filename = "formatted_MDCINT"
        else
            write (chr_idx, *) idx
            if (idx < 10) then
                padding_x = "XXXX"
            else if (idx < 100) then
                padding_x = "XXX"
            else if (idx < 1000) then
                padding_x = "XX"
            else if (idx < 10000) then
                padding_x = "X"
            else if (idx < 100000) then
                padding_x = ""
            end if
            filename = "MDCIN"//trim(adjustl(padding_x))//trim(adjustl(chr_idx))
            output_filename = "formatted_MDCINT"//trim(adjustl(chr_idx))
        end if
    end subroutine get_filename
end Program convert_mdcint
