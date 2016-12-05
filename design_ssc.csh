#!/usr/bin/csh
source /apps/set_license

setenv STROOT /apps/synopsys/TCAD
setenv STRELEASE current
setenv ISEROOT /apps/synopsys/TCAD/
setenv STDB ${HOME}/sentaurus


setenv SYNOPSYS /apps/synopsys
setenv PRIMETIME_ROOT $SYNOPSYS/pt2000.11
setenv SYNOPSYS_SIM $SYNOPSYS/2000.12
setenv CLS_CSD_COMPATIBILITY_LOCKING NO
setenv SKIP_CDS_DIALOG

# Set tool locations (note that $CDS is needed by dfiiwrapper.pl)

setenv CDS /apps/cadence 
setenv IC  $CDS/IC50
setenv IUS $CDS/INCISIV141
setenv cdk_dir $IC/tools/dfII/local
#setenv ASSURAHOME  $CDS/ASSURA
 
# the lib path setup looks at $CDS_SITE/cdssetup to find the "setup.loc"
# file (other things, like prependNCSUCDKInstallPath(), need $CDS_SITE
# as well) 

setenv CDS_SITE /apps/cadence/IC50/tools/dfII/local
setenv USE_NCSU_CDK  
setenv CDS_VHDL $IUS/tools/leapfrog

# use analog netlister for everything

setenv CDS_Netlisting_Mode Analog

# this sets things so we no longer use cdsd. this won't be a problem,
# since we're not running 442 anymore. plus it makes the tools run on
# solaris 2.6! yay!

setenv CLS_CDSD_COMPATIBILITY_LOCKING NO

# this next one sets a path to our wrapper script; the script
# removes this PATH component to unmask the real executable
#
# note that we have to do this explicitly, rather than using prepend,
# because the "add" that got us here already added $CDS/bin, and we want
# it at the front of PATH (prepend won't add it if it's already there)

#extend MANPATH $IUS/share/man
#extend MANPATH $IC/share/man
#extend MANPATH $IC/tools/man


setenv PATH "/apps/synopsys/TCAD/bin:${PATH}"
setenv PATH "/apps/synopsys/K-2015.06-SP5-1_power_compiler/bin:${PATH}"
setenv PATH "${PATH}:/apps/silvaco/bin"
setenv PATH "${PATH}:/apps/cadence/IC50/tools/perl/bin"
setenv PATH "${PATH}:/apps/cadence/SOC42/bin:/apps/SOC42/share/celtic/scripts"
setenv PATH "${PATH}:${CDS}/bin"
setenv PATH "${PATH}:${CDS_VHDL}"
setenv PATH "${PATH}:${IC}/tools/bin"
setenv PATH "${PATH}:${IC}/tools/dfII/bin"
setenv PATH "${PATH}:${IC}/tools/concice/bin"
setenv PATH "${PATH}:${IC}/tools/dracula/bin"
setenv PATH "${PATH}:${IUS}/tools/bin"
setenv PATH "${PATH}:/apps/altera8.1/quartus/bin"

setenv LD_LIBRARY_PATH /apps/synopsys/TCAD/tcad/current/linux/lib
setenv LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:${IUS}/tools/lib
setenv LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:${IC}/tools/lib

setenv HSP_HOME /apps/synopsys/HSPICE/hspice
setenv VCS_HOME /apps/synopsys/I-2014.03-2
source ${VCS_HOME}/bin/environ.csh

