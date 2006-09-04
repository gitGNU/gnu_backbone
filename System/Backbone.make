BBFRAMEWORKS=$(TOP_SRCDIR)/Frameworks

#
# Framework stuff
#
# To use this, set the variable FRAMEWORKS to a space-separated list of
# framework BASE NAMES (no .framework extension). All project types that link
# with shlibs will automatically link with the frameworks named in FRAMEWORKS.
# 
define FRAMEWORK_link
fw := $(1)
AUXILIARY_OBJC_LIBS += -l$(fw)
AUXILIARY_LIB_DIRS += -L$(BBFRAMEWORKS)/$(fw)/$(fw).framework/Versions/Current/$(GNUSTEP_LDIR)
endef

$(foreach fw,$(FRAMEWORKS), $(eval $(call FRAMEWORK_link, $(fw))))

ifneq ($(FRAMEWORKS),)
ADDITIONAL_INCLUDE_DIRS += -I$(BBFRAMEWORKS)
endif

BACKBONE_VERSION=0.0.1
