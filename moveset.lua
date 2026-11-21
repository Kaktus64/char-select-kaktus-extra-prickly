---@diagnostic disable: undefined-global
if not _G.charSelectExists then return end

local function limit_angle(a)
    return (a + 0x8000) % 0x10000 - 0x8000
end

local gStateExtras = {}
for i = 0, MAX_PLAYERS - 1 do
    gStateExtras[i] = {}
    local m = gMarioStates[i]
    local e = gStateExtras[i]
    e.rotAngle = 0
    e.canBrella = true
    e.charArg = 0
    e.flyFloor = 0
end

local brellaActions = { -- What actions you can brella out of
    [ACT_JUMP] = true,
    [ACT_DOUBLE_JUMP] = true,
    [ACT_TRIPLE_JUMP] = true,
    [ACT_LONG_JUMP] = true,
    [ACT_FREEFALL] = true,
    [ACT_SIDE_FLIP] = true,
    [ACT_BACKFLIP] = true,
    [ACT_WALL_KICK_AIR] = true,
    [ACT_TOP_OF_POLE_JUMP] = true,
    [ACT_SHOT_FROM_CANNON] = true,
    [ACT_WATER_JUMP] = true,
}


ACT_BRELLA_FLOAT = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR)
--ACT_BRELLA_THRUST = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_ATTACKING)
--ACT_BRELLA_THRUST_AIR = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_ATTACKING)
--ACT_BRELLA_LUNGE = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_DIVING)
ACT_KAK_ROLL_AIR = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ATTACKING | ACT_FLAG_DIVING)
ACT_KAK_ROLL = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_ATTACKING)

function act_brella_float(m)
    local anim = CHAR_ANIM_HANG_ON_CEILING

    m.marioBodyState.handState = MARIO_HAND_PEACE_SIGN
    --set_mario_particle_flags(m, PARTICLE_SPARKLES, 0)
    
    m.faceAngle.y = m.intendedYaw - approach_s32(limit_angle(m.intendedYaw - m.faceAngle.y), 0, 0x200, 0x200)
    m.marioBodyState.eyeState = MARIO_EYES_LOOK_DOWN
    m.peakHeight = m.pos.y -- no fall sound

    local stepResult = common_air_action_step(m, ACT_FREEFALL_LAND, anim, AIR_STEP_CHECK_LEDGE_GRAB)
    --[[
    if m.vel.y < 0 then
        m.vel.y = math.lerp(m.vel.y, -m.actionTimer/300, 0.1)
    elseif m.floor.type == SURFACE_VERTICAL_WIND then -- updraft
        m.vel.y = m.vel.y + 1
    else
        m.vel.y = m.vel.y + 3 -- lets you bounce off goombas
    end
    ]]
    if m.forwardVel > 40 then
        m.forwardVel = m.forwardVel - 1
    end
    if stepResult == AIR_STEP_LANDED then
        set_mario_action(m, ACT_FREEFALL_LAND, 0)
    end
    if stepResult == AIR_STEP_HIT_WALL and m.forwardVel ~= 0 then
        mario_bonk_reflection(m, 1)
        set_mario_action(m, ACT_BRELLA_FLOAT, 0)
        m.actionTimer = 10
    end
    if m.input & INPUT_A_DOWN == 0 then
        set_mario_action(m, ACT_FREEFALL, 0)
    end
    if m.input & INPUT_B_PRESSED ~= 0 then
        m.forwardVel = 25
        m.actionTimer = 0
        m.vel.y = 25
        set_mario_action(m, ACT_DIVE, 0)
    end
    if m.input & INPUT_Z_PRESSED ~= 0 then
        set_mario_action(m, ACT_GROUND_POUND, 0)
    end
    if m.actionTimer > 35 then
        m.vel.y = m.vel.y * 1.02
    end
    if m.forwardVel > 27 then
        m.forwardVel = m.forwardVel - 1.35
    end
    m.actionTimer = m.actionTimer + 1
    return false
end

function act_brella_float_gravity(m)
    if m.floor.type == SURFACE_VERTICAL_WIND then -- updraft
        m.vel.y = math.min(m.vel.y + 1, 50)
        m.actionTimer = 0
    else
        m.vel.y = math.lerp(m.vel.y, -m.actionTimer*0.17 - 0.5, 0.1)
    end
    return false
end


hook_mario_action(ACT_BRELLA_FLOAT, {every_frame = act_brella_float, gravity = act_brella_float_gravity})
--[[
function act_brella_thrust(m)
    local e = gStateExtras[m.playerIndex]
    local stepResult = perform_ground_step(m)
    m.faceAngle.y = m.intendedYaw - approach_s32(limit_angle(m.intendedYaw - m.faceAngle.y), 0, 0x80, 0x80)

    m.marioBodyState.handState = MARIO_HAND_PEACE_SIGN
    set_mario_animation(m, CHAR_ANIM_FIRST_PUNCH)
    apply_slope_accel(m)
    if m.marioObj.header.gfx.animInfo.animFrame > 2 then
        set_anim_to_frame(m, 3)
    end

    m.forwardVel = m.forwardVel - 2
    if m.forwardVel > 30 then
    set_mario_particle_flags(m, PARTICLE_TRIANGLE, 0)
    end
    if stepResult == GROUND_STEP_LEFT_GROUND then
        set_mario_action(m, ACT_FREEFALL, 0)
    end
    if stepResult == GROUND_STEP_HIT_WALL then
        set_mario_action(m, ACT_BACKWARD_AIR_KB, 0)
        set_mario_particle_flags(m, PARTICLE_VERTICAL_STAR, 0)
        play_sound(SOUND_ACTION_HIT, m.marioObj.header.gfx.cameraToObject)
    end
    --if m.actionTimer > 11 then
        --set_mario_action(m, ACT_WALKING, 0)
    --end
    if m.forwardVel > 110
    then m.forwardVel = 110
    end
    if m.forwardVel < 15 then
        set_mario_action(m, ACT_LONG_JUMP_LAND, 0)
    end
    if m.input & INPUT_A_PRESSED ~= 0 then
        m.pos.y = m.pos.y + 1
        m.vel.y = 45
        set_mario_particle_flags(m, PARTICLE_MIST_CIRCLE, 0)
        set_anim_to_frame(m, 0)
        m.actionTimer = 0
        e.rotAngle = 0
        set_mario_action(m, ACT_BRELLA_LUNGE, 0)
        play_sound(SOUND_GENERAL_BOING2, m.marioObj.header.gfx.cameraToObject)

    end
    if m.input & INPUT_B_PRESSED ~= 0 and m.actionTimer > 1 and m.forwardVel < 60 then
        set_mario_action(m, ACT_FORWARD_ROLLOUT, 0)
        set_mario_particle_flags(m, PARTICLE_MIST_CIRCLE, 0)
        set_anim_to_frame(m, 0)
        if m.forwardVel > 55 then
            m.forwardVel = 55
        end
    end
    if m.actionTimer % 3 == 0 then
        play_sound(SOUND_ACTION_CLIMB_UP_TREE, m.marioObj.header.gfx.cameraToObject)
    end
    --apply_slope_accel(m)
    --apply_slope_decel(m, 0.08)
    m.actionTimer = m.actionTimer + 1
end

hook_mario_action(ACT_BRELLA_THRUST, act_brella_thrust)

function act_brella_thrust_air(m)
    local e = gStateExtras[m.playerIndex]
    local stepResult = common_air_action_step(m, ACT_BRELLA_THRUST, CHAR_ANIM_FIRST_PUNCH, AIR_STEP_CHECK_LEDGE_GRAB)
    m.faceAngle.y = m.intendedYaw - approach_s32(limit_angle(m.intendedYaw - m.faceAngle.y), 0, 0x80, 0x80)

    m.marioBodyState.handState = MARIO_HAND_PEACE_SIGN
    --set_mario_animation(m, CHAR_ANIM_FIRST_PUNCH)
    --apply_slope_accel(m)
    if m.marioObj.header.gfx.animInfo.animFrame > 2 then
        set_anim_to_frame(m, 3)
    end

    m.forwardVel = m.forwardVel - 1
    if m.forwardVel > 30 then
    set_mario_particle_flags(m, PARTICLE_TRIANGLE, 0)
    end
    if stepResult == AIR_STEP_LANDED then
        set_mario_action(m, ACT_BRELLA_THRUST, 0)
    end
    if stepResult == AIR_STEP_HIT_WALL and m.forwardVel ~= 0 then
        mario_bonk_reflection(m, 1)
        set_mario_action(m, ACT_AIR_HIT_WALL, 0)
        m.actionTimer = 10
    end
    --if m.actionTimer > 11 then
        --set_mario_action(m, ACT_WALKING, 0)
    --end
    if m.forwardVel > 110
    then m.forwardVel = 110
    end
    if m.forwardVel < 15 then
        set_mario_action(m, ACT_LONG_JUMP_LAND, 0)
    end
    if m.input & INPUT_A_PRESSED ~= 0 then
        m.pos.y = m.pos.y + 1
        m.vel.y = 45
        set_mario_particle_flags(m, PARTICLE_MIST_CIRCLE, 0)
        set_anim_to_frame(m, 0)
        m.actionTimer = 0
        e.rotAngle = 0
        set_mario_action(m, ACT_BRELLA_LUNGE, 0)
        play_sound(SOUND_GENERAL_BOING2, m.marioObj.header.gfx.cameraToObject)

    end
    if m.input & INPUT_B_PRESSED ~= 0 and m.actionTimer > 1 and m.forwardVel < 60 then
        set_mario_action(m, ACT_FORWARD_ROLLOUT, 0)
        set_mario_particle_flags(m, PARTICLE_MIST_CIRCLE, 0)
        set_anim_to_frame(m, 0)
        if m.forwardVel > 55 then
            m.forwardVel = 55
        end
    end
    if m.actionTimer % 3 == 0 then
        play_sound(SOUND_ACTION_CLIMB_UP_TREE, m.marioObj.header.gfx.cameraToObject)
    end
    --apply_slope_accel(m)
    --apply_slope_decel(m, 0.08)
    m.actionTimer = m.actionTimer + 1
end

hook_mario_action(ACT_BRELLA_THRUST_AIR, act_brella_thrust_air)

function act_brella_lunge(m)
    local e = gStateExtras[m.playerIndex]
    local stepResult = common_air_action_step(m, ACT_LONG_JUMP_LAND, CHAR_ANIM_GRAB_POLE_SWING_PART2, AIR_STEP_NONE)
    m.marioBodyState.handState = MARIO_HAND_PEACE_SIGN
    e.rotAngle = m.vel.y * -200
    m.marioObj.header.gfx.angle.x = e.rotAngle
    m.marioBodyState.eyeState = MARIO_EYES_LOOK_DOWN
    if m.actionTimer % 10 == 0 then
        --play_sound(SOUND_ACTION_TWIRL, m.marioObj.header.gfx.cameraToObject)
    end
    if m.forwardVel > 55 then
        m.forwardVel = m.forwardVel - 1.5
    end
    if m.vel.y < 0 then m.vel.y = m.vel.y + 2.25 end
    m.actionTimer = m.actionTimer + 1
    m.faceAngle.y = m.intendedYaw - approach_s32(math.s16(m.intendedYaw - m.faceAngle.y), 0, 0x040, 0x040)
    if m.actionTimer > 10 and (m.flags & MARIO_WING_CAP) ~= 0 then
        set_mario_action(m, ACT_FLYING_TRIPLE_JUMP, 0)
        m.vel.y = 0
    end
end

hook_mario_action(ACT_BRELLA_LUNGE, act_brella_lunge)
--]]
function act_kak_roll_air(m)
    local e = gStateExtras[m.playerIndex]
    
    if m.actionTimer < 4 and m.action == ACT_KAK_ROLL_AIR then
        m.vel.y = 5
        m.vel.x = 0
        m.vel.z = 0
        m.forwardVel = 0
        set_mario_animation(m, CHAR_ANIM_GENERAL_LAND)
    end
    if m.actionTimer > 4 and m.actionTimer < 9 then
        
        m.pos.y = m.pos.y + 5
        m.vel.y = 21
        m.forwardVel = m.forwardVel + 12
    end
    if m.actionTimer > 4 and m.actionTimer < 6 then
        play_sound(SOUND_ACTION_TWIRL, m.marioObj.header.gfx.cameraToObject)
    end
    if m.actionTimer > 4 then
        local stepResult = common_air_action_step(m, ACT_KAK_ROLL, CHAR_ANIM_FORWARD_SPINNING_FLIP, AIR_STEP_NONE)

    end
    --if m.actionTimer > 15 then
        --set_mario_animation(m, CHAR_ANIM_DIVE)
        --set_mario_action(m, ACT_DIVE, 0)
    --end
    --m.marioBodyState.handState = MARIO_HAND_PEACE_SIGN
    --e.rotAngle = m.vel.y * -200
    --m.marioObj.header.gfx.angle.x = e.rotAngle
    
    m.marioBodyState.eyeState = MARIO_EYES_LOOK_DOWN
    if m.actionTimer % 10 == 0 then
        
    end
    if m.forwardVel > 70 then
        m.forwardVel = 69
    end
    --if m.vel.y < 0 then m.vel.y = m.vel.y + 2.25 end
    m.actionTimer = m.actionTimer + 1
    m.faceAngle.y = m.intendedYaw - approach_s32(math.s16(m.intendedYaw - m.faceAngle.y), 0, 0x150, 0x150)
    --if m.actionTimer > 10 and (m.flags & MARIO_WING_CAP) ~= 0 then
        --set_mario_action(m, ACT_FLYING_TRIPLE_JUMP, 0)
        --m.vel.y = 0
    --end
end

hook_mario_action(ACT_KAK_ROLL_AIR, act_kak_roll_air)

function act_kak_roll(m)
    local e = gStateExtras[m.playerIndex]

    e.rotAngle = e.rotAngle + 3000
    m.marioObj.header.gfx.angle.z = e.rotAngle

    local stepResult = common_slide_action(m, ACT_HOLD_BUTT_SLIDE_STOP, ACT_BUTT_SLIDE_STOP, CHAR_ANIM_FORWARD_SPINNING)

    tilt_body_running(m)
    
    --if m.actionTimer > 15 then
        --set_mario_animation(m, CHAR_ANIM_DIVE)
        --set_mario_action(m, ACT_DIVE, 0)
    --end
    --m.marioBodyState.handState = MARIO_HAND_PEACE_SIGN
    --e.rotAngle = m.vel.y * -200
    --m.marioObj.header.gfx.angle.x = e.rotAngle
    m.marioBodyState.eyeState = MARIO_EYES_LOOK_DOWN
    apply_slope_accel(m)
    m.forwardVel = m.forwardVel - 0.5
    if m.forwardVel > 110
    then m.forwardVel = 110
    end
    if m.forwardVel < 15 then
        set_mario_action(m, ACT_BUTT_SLIDE_STOP, 0)
    end
    if m.input & INPUT_A_PRESSED ~= 0 and m.actionTimer > 1 and m.forwardVel < 60 then
        set_mario_action(m, ACT_FORWARD_ROLLOUT, 0)
        set_mario_particle_flags(m, PARTICLE_MIST_CIRCLE, 0)
        set_anim_to_frame(m, 0)
        if m.forwardVel > 55 then
            m.forwardVel = 55
        end
    end
    if m.input & INPUT_B_PRESSED ~= 0 and m.actionTimer > 1 and m.forwardVel < 60 then
        set_mario_action(m, ACT_FORWARD_ROLLOUT, 0)
        set_mario_particle_flags(m, PARTICLE_MIST_CIRCLE, 0)
        set_anim_to_frame(m, 0)
        if m.forwardVel > 55 then
            m.forwardVel = 55
        end
    end
    m.faceAngle.y = m.intendedYaw - approach_s32(limit_angle(m.intendedYaw - m.faceAngle.y), 0, 0x80, 0x80)
    if m.actionTimer % 10 == 0 then
        play_sound(SOUND_ACTION_SPIN, m.marioObj.header.gfx.cameraToObject)
    end
    --if m.forwardVel > 50 then
        --m.forwardVel = 49
    --end
    --if m.vel.y < 0 then m.vel.y = m.vel.y + 2.25 end
    m.actionTimer = m.actionTimer + 1
    m.faceAngle.y = m.intendedYaw - approach_s32(math.s16(m.intendedYaw - m.faceAngle.y), 0, 0x300, 0x300)
    --if m.actionTimer > 10 and (m.flags & MARIO_WING_CAP) ~= 0 then
        --set_mario_action(m, ACT_FLYING_TRIPLE_JUMP, 0)
        --m.vel.y = 0
    --end
end

hook_mario_action(ACT_KAK_ROLL, act_kak_roll)

function kaktus_update(m)

    local e = gStateExtras[m.playerIndex]

    if brellaActions[m.action] and m.vel.y < 0 and m.input & INPUT_A_PRESSED ~= 0 and e.canBrella then
        set_mario_action(m, ACT_BRELLA_FLOAT, 0)
        set_mario_particle_flags(m, PARTICLE_MIST_CIRCLE, 0)
        play_sound(SOUND_TERRAIN_WATER, m.marioObj.header.gfx.cameraToObject)
        e.canBrella = false
        -- Fix Camera from acts like Cannon
        if m.playerIndex == 0 then
            if (not camera_config_is_free_cam_enabled()) then
                set_camera_mode(m.area.camera, m.area.camera.defMode, 1);
            else
                m.area.camera.mode = CAMERA_MODE_NEWCAM;
                gLakituState.mode = CAMERA_MODE_NEWCAM;
            end
        end
    end

    if m.pos.y == m.floorHeight then
        e.canBrella = true
    end

end

function kaktus_before_set_action(m, inc)

    local e = gStateExtras[m.playerIndex]
    --[[
    if inc == ACT_DIVE and m.pos.y == m.floorHeight and m.action ~= ACT_KAK_ROLL_AIR then
        m.forwardVel = 70
        m.actionTimer = 0
        return ACT_BRELLA_THRUST
    end

    if inc == ACT_DIVE and m.pos.y ~= m.floorHeight and m.action ~= ACT_KAK_ROLL_AIR then
        m.forwardVel = 70
        m.actionTimer = 0
        return ACT_BRELLA_THRUST_AIR
    end
    --]]
    if inc == ACT_DOUBLE_JUMP then
        return ACT_JUMP
    end

    if inc == ACT_LONG_JUMP then
        m.pos.y = m.pos.y + 5
        --m.forwardVel = m.forwardVel + 30
        --m.vel.y = 25
        m.actionTimer = 0
        return ACT_KAK_ROLL_AIR
    end

end

_G.charSelect.character_hook_moveset(CT_KAKTUS, HOOK_MARIO_UPDATE, kaktus_update)
_G.charSelect.character_hook_moveset(CT_KAKTUS, HOOK_BEFORE_SET_MARIO_ACTION, kaktus_before_set_action)