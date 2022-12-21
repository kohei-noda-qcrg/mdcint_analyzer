!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Program readmdcint

! ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    Implicit None
    Character  :: datex*10, timex*8
    character(50) :: mdcint_filename, mdcint_output_filename
    integer :: nkr, nmo, mdcint_unit = 10, file_output_unit = 11
    integer :: i, i0, inz, nz, ikr, jkr, stat, mdcint_idx, tmp_nkr
    integer, allocatable :: indk(:), indl(:), kr(:)
    double precision, allocatable  :: rklr(:), rkli(:)
    logical :: realonly, exists

    open (mdcint_unit, file="MDCINT", form="unformatted", status="unknown")
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
    read (mdcint_unit, iostat=stat) ikr, jkr, nz, (indk(inz), indl(inz), inz=1, nz), (rklr(inz), rkli(inz), inz=1, nz)
    print *, "realonly = ", realonly
    close (mdcint_unit)
    if (stat /= 0) then
        realonly = .true.
    else
        realonly = .false.
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
        open (mdcint_unit, file=trim(mdcint_filename), form="unformatted", status="unknown")
        open (file_output_unit, file=trim(mdcint_output_filename), form="formatted", status="unknown")
        rewind (mdcint_unit)
        read (mdcint_unit) datex, timex, nkr, (kr(i0), kr(-1*i0), i0=1, nkr)
        write (file_output_unit, *) datex, timex, nkr, (kr(i0), kr(-1*i0), i0=1, nkr)
!        if (mdcint_idx == 0) then
!            read (mdcint_unit) datex, timex, nkr, (kr(i0), kr(-1*i0), i0=1, nkr)
!            write (file_output_unit, *) datex, timex, nkr, (kr(i0), kr(-1*i0), i0=1, nkr)
!        else
!            read (mdcint_unit) datex, timex, tmp_nkr
!            write (file_output_unit, *) datex, timex, tmp_nkr
!        end if
        do
            if (realonly) then
                read (mdcint_unit, iostat=stat) ikr, jkr, nz, (indk(inz), indl(inz), inz=1, nz), (rklr(inz), inz=1, nz)
            else
                read (mdcint_unit, iostat=stat) ikr, jkr, nz, (indk(inz), indl(inz), inz=1, nz), (rklr(inz), rkli(inz), inz=1, nz)
            end if
            if (ikr == 0) then
                exit
            end if
            if (stat < 0) then
                print *, "End of file"
                exit
            else if (stat > 0) then
                print *, "Error while reading file. iostat = ", stat
                stop
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
        close (file_output_unit)
        mdcint_idx = mdcint_idx + 1
    end do

    deallocate (kr)
    deallocate (indk)
    deallocate (indl)
    deallocate (rklr)
    deallocate (rkli)

    print *, "End program normally"
contains
    subroutine get_filename(idx, filename, output_filename)
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
end Program readmdcint
