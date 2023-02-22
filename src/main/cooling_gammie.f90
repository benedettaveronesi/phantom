!--------------------------------------------------------------------------!
! The Phantom Smoothed Particle Hydrodynamics code, by Daniel Price et al. !
! Copyright (c) 2007-2023 The Authors (see AUTHORS)                        !
! See LICENCE file for usage and distribution conditions                   !
! http://phantomsph.bitbucket.io/                                          !
!--------------------------------------------------------------------------!
module cooling_gammie
!
! Simple beta-cooling prescription used for experiments on gravitational
!  instability in discs
!
! :References:
!   Gammie (2001), ApJ 553, 174-183
!
! :Owner: Daniel Price
!
! :Runtime parameters:
!   - beta_cool : *beta factor in Gammie (2001) cooling*
!
! :Dependencies: infile_utils, io
!
 implicit none
 real, private :: beta_cool  = 3., beta_cool_in = 3., rcav = 5.

contains
!-----------------------------------------------------------------------
!+
!   Gammie (2001) cooling
!+
!-----------------------------------------------------------------------
subroutine cooling_Gammie_explicit(xi,yi,zi,ui,dudti)

 real, intent(in)    :: ui,xi,yi,zi
 real, intent(inout) :: dudti

 real :: omegai,r2,tcool1,beta_mod

 r2     = xi*xi + yi*yi + zi*zi
 Omegai = r2**(-0.75)

 if (r2 <= rcav**2) then
      beta_mod = max( beta_cool*(r2/rcav**2), beta_cool_in)
      tcool1 = Omegai/beta_mod
 else
      tcool1 = Omegai/beta_cool
 endif

 !tcool1 = Omegai/beta_cool
 dudti  = dudti - ui*tcool1

end subroutine cooling_Gammie_explicit

!-----------------------------------------------------------------------
!+
!  writes input options to the input file
!+
!-----------------------------------------------------------------------
subroutine write_options_cooling_gammie(iunit)
 use infile_utils, only:write_inopt
 integer, intent(in) :: iunit

 call write_inopt(beta_cool,'beta_cool','beta factor in Gammie (2001) cooling',iunit)
 call write_inopt(beta_cool_in,'beta_cool_in','beta factor inside the cavity',iunit)
 call write_inopt(rcav, 'rcav', 'size of the expected cavity',iunit)

end subroutine write_options_cooling_gammie

!-----------------------------------------------------------------------
!+
!  reads input options from the input file
!+
!-----------------------------------------------------------------------
subroutine read_options_cooling_gammie(name,valstring,imatch,igotall,ierr)
 use io, only:fatal
 character(len=*), intent(in)  :: name,valstring
 logical,          intent(out) :: imatch,igotall
 integer,          intent(out) :: ierr
 integer, save :: ngot = 0

 imatch  = .true.
 igotall = .false. ! cooling options are compulsory
 select case(trim(name))
 case('beta_cool')
    read(valstring,*,iostat=ierr) beta_cool
    ngot = ngot + 1
    if (beta_cool < 1.) call fatal('read_options','beta_cool must be >= 1')
 case('beta_cool_in')
    read(valstring,*,iostat=ierr) beta_cool_in
    ngot = ngot + 1
 case('rcav')
    read(valstring,*,iostat=ierr) rcav
    ngot = ngot + 1
 case default
    imatch = .false.
 end select
 if (ngot >= 1) igotall = .true.

end subroutine read_options_cooling_gammie

end module cooling_gammie
