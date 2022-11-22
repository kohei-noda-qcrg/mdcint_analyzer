!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

Program readmdcint

! ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    Implicit None
    Character  :: datex*10, timex*8
    integer :: nkr, nmo, mdcint_unit = 10, file_output_unit = 11
    integer :: i, i0, inz, nz, ikr, jkr, stat
    integer, allocatable :: indk(:), indl(:), kr(:)
    double precision, allocatable  :: rklr(:), rkli(:)
    logical :: realonly

    open (file_output_unit, file="debug", form="formatted", status="unknown")
    open (mdcint_unit, file="MDCINT", form="unformatted", status="unknown")

    read (mdcint_unit) datex, timex, nkr
    rewind (mdcint_unit)
    nmo = 2*nkr
    allocate (kr(-nkr:nkr))
    kr(:) = 0
    read (mdcint_unit) datex, timex, nkr, (kr(i0), kr(-1*i0), i0=1, nkr)
    write (file_output_unit, *) datex, timex, nkr, (kr(i0), kr(-1*i0), i0=1, nkr)
    allocate (indk(nmo**2))
    allocate (indl(nmo**2))
    allocate (rklr(nmo**2))
    allocate (rkli(nmo**2))
    read (mdcint_unit, iostat=stat) ikr, jkr, nz, (indk(inz), indl(inz), inz=1, nz), (rklr(inz), rkli(inz), inz=1, nz)
    if (stat /= 0) then
        realonly = .true.
    else
        realonly = .false.
    end if
    print *, "realonly = ", realonly
    rewind (mdcint_unit)
    read (mdcint_unit)
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
    close (file_output_unit)
    close (mdcint_unit)

    deallocate (kr)
    deallocate (indk)
    deallocate (indl)
    deallocate (rklr)
    deallocate (rkli)

    print *, "End program normally"

end Program readmdcint
