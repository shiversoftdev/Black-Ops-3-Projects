GetNormalTrace(distance = 1000000)
{
    return bullettrace(self GetEye(), self GetEye() + anglesToForward(self getplayerangles()) * distance, 0, self);
}

GetTraceOrigin(distance = 1000000)
{
    return self GetNormalTrace(distance)["position"];
}

santize_camoname(camoname)
{
    if(!isdefined(camoname))
        return;
    
    result = "";
    i = 0;

    if(camoname[i] == "c")
        i = 5;

    for(; i < camoname.size; i++)
    {
        if(camoname[i] == "_")
            continue;
        
        result += camoname[i];
    }

    return result;
}

true_one_arg(arg)
{
    return true;
}

nullsub(){}