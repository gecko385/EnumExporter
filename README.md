# EnumExporter

Yet another Perl Enumerated Types. Similar to enum but auto-exports as Readonly vars

Shameless rip off of Neil Bowers/Byron Brummer's [enum.pm](https://metacpan.org/pod/enum). 

Differences are:

  1. separated the bitmask stuff into a (future) seperate
     module, you can do either but not both together,
     all looked a bit messy.

  2. replace subs creation with [Readonly](https://metacpan.org/pod/Readonly) variables
     as my target app has around 600 enums to wrap
     and thats a lot of subs, few of which will ever get
     used at any one time. I believe lots of unused RO vars is
     better than lots of unused subs (?)

  3. Automatically push each variable name onto the callers
     `@EXPORT_OK.`

 This is all designed to be used when you want to put enums
 into a separate package, then export them as readonly vars.
 The identifiers can have a postfix `'=<numeric>'` to set reset
 the initializer for subsequent identifiers, ala C and ala
 the original enum pkg. The regexp parsing is lifted straight
 from `enum.pm`

# Synopsis

 ## Package that builds the enumerated types and exports them...
 ```
 package GUI::LabelTypes;
 use Readonly qw( Readonly );
 use Enum qw /export_ro/;
 use base 'Exporter';
 our @EXPORT_OK;

 export_ro qw/
       GUI_NORMAL_LABEL=0
       GUI_NO_LABEL
       GUI_SHADOW_LABEL
       GUI_ENGRAVED_LABEL
       GUI_EMBOSSED_LABEL
       GUI_MULTI_LABEL
       GUI_ICON_LABEL
       GUI_IMAGE_LABEL
       GUI_FREE_LABELTYPE /;
 1;
 ```
## Package that uses the enumerated types... 

```
Package GUI;
use GUI::LabelTypes qw / $GUI_SHADOW_LABEL /;
...
createLabel($GUI_SHADOW_LABEL);
```
# Acknowledgements

Neil Bowers/Byron Brummer+others for the [enum package](https://metacpan.org/pod/enum). 
 
Sanko Robinson/Eric J. Roode + others for the [Readonly package](https://metacpan.org/pod/Readonly) 

# Author

Gracey Shaw (gecko385)
  
# License and Legal

Copyright (C) Gracey Shaw (gecko385)

This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself.
