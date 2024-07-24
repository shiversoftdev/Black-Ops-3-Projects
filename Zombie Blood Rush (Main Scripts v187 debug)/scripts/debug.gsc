debug_sphere(origin, radius, color, alpha, time, depthtest = 1)
{
    if(!DEBUG_DEVELOPER)
    {
        return;
    }
    if(!isdefined(time))
    {
        time = 1000;
    }
    if(!isdefined(color))
    {
        color = (1, 1, 1);
    }
    sides = int(10 * (1 + (int(radius) % 100)));
    // origin, radius, color, alpha, depthtest, sides, time
    sphere(origin, radius, color, alpha, depthtest, sides, time);
}

debug_text(origin, text, color, alpha, scale, duration)
{
    print3d(origin, text, color, alpha, scale, duration);
}

// circle
// line