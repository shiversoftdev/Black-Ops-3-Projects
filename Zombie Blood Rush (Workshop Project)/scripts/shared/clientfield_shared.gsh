#define REFIELD_SAFETY_WRAP(name_str,name) case name_str: level._cscfieldwrappers[name_str] = func_callback; func_callback = & name; break;
#define REFIELD_SAFETY_FN(name_str,name) function name (localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump) \
    {\
        if(!isdefined(level._cscfieldwrapperstates[localclientnum]))\
        {\
            level._cscfieldwrapperstates[localclientnum] = [];\
        }\
        if(!isdefined(level._cscfieldwrapperstates[localclientnum][name_str]))\
        {\
            level._cscfieldwrapperstates[localclientnum][name_str] = false;\
        }\
        if(isdefined(oldval) && isdefined(newval) && (oldval == newval) && level._cscfieldwrapperstates[localclientnum][name_str])\
        {\
            return;\
        }\
        if(isdefined(bwastimejump) && bwastimejump && !binitialsnap)\
        {\
            return;\
        }\
        if(!level._cscfieldwrapperstates[localclientnum][name_str])\
        {\
            level._cscfieldwrapperstates[localclientnum][name_str] = true;\
        }\
        self [[ level._cscfieldwrappers[ name_str ] ]](localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump);\
    }

#define REFIELD_SAFETY_FN_ENT(name_str,name) function name (localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump) \
    {\
        if(!isdefined(self._cscfieldwrapperstates))\
        {\
            self._cscfieldwrapperstates = [];\
        }\
        if(!isdefined(self._cscfieldwrapperstates[localclientnum]))\
        {\
            self._cscfieldwrapperstates[localclientnum] = [];\
        }\
        if(!isdefined(self._cscfieldwrapperstates[localclientnum][name_str]))\
        {\
            self._cscfieldwrapperstates[localclientnum][name_str] = false;\
        }\
        if(isdefined(oldval) && isdefined(newval) && (oldval == newval) && self._cscfieldwrapperstates[localclientnum][name_str])\
        {\
            return;\
        }\
        if(isdefined(bwastimejump) && bwastimejump && !binitialsnap)\
        {\
            return;\
        }\
        if(!self._cscfieldwrapperstates[localclientnum][name_str])\
        {\
            self._cscfieldwrapperstates[localclientnum][name_str] = true;\
        }\
        self [[ level._cscfieldwrappers[ name_str ] ]](localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump);\
    }


    /*[[ &sys::isprofilebuild ]](0x1223EC94, name_str + ": isfirst(" + !level._cscfieldwrapperstates[localclientnum][name_str] + ") o(" + (isdefined(oldval) ? oldval : "u") + ") n(" + (isdefined(newval) ? newval : "u") + ") bnewent(" + (isdefined(bnewent) ? bnewent : "u") + ") binitialsnap(" + (isdefined(binitialsnap) ? binitialsnap : "u") + ") bwastimejump(" + (isdefined(bwastimejump) ? bwastimejump : "u") + ")");*/