one_inch_punch_dmg(attacker, is_upgraded = 0)
{
    alpha = min(1, distancesquared(attacker.origin, self.origin) / (4096 * (1 + is_upgraded)));
    velocity = LerpFloat(OIP_LAUNCH_MIN_VELOCITY, OIP_LAUNCH_MAX_VELOCITY, 1 - alpha);
    angles = VectorNormalize(anglesToForward(attacker getPlayerAngles()));

    final_velocity = angles * velocity;
    final_velocity_clamped = (final_velocity[0], final_velocity[1], 400);

    self setOrigin(self getOrigin() + (0,0,10));
    self setVelocity(final_velocity_clamped);
    self.launch_magnitude_extra = 200;
    self.v_launch_direction_extra = vectorNormalize(final_velocity_clamped);
}