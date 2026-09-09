--[[
    Zooz Z-Box / FIBARO HC3
    Enable Unavailable Notifications
    
    PLEASE READ:
    Quickly coded by Darren at SaveThePanel.com with AI assistance.
    USE THIS CODE AT YOUR OWN RISK and PLEASE VERIFY its operation before executing.


    DISCLAIMER:
    This script is provided for informational and educational purposes
    only and is provided "AS IS" without warranty of any kind.

    This script makes configuration changes to your Z-Box hub. Review
    and understand the code before running it, and back up your hub
    configuration before making bulk changes.

    Use at your own risk. The author and SaveThePanel are not
    responsible for data loss, configuration changes, device behavior,
    notification charges, or other damages resulting from its use.

    This is an independent community-developed script and is not
    affiliated with, endorsed by, or supported by Zooz or FIBARO.

    Tested configuration/firmware: [INSERT VERSION]
    Last updated: September 9, 2026




    Configuration applied:
      Unavailable: ENABLED
      Interval:    Once
      Channels:    E-mail + Push
      User:        admin

    Other notification types are left untouched.
    
--]]

--------------------------------------------------
-- SETTINGS
--------------------------------------------------

local ADMIN_USERNAME = "admin"

-- Set to true first if you want to see what WOULD change
-- without actually writing anything.
-- Must be set to false to actually make changes
local DRY_RUN = true


--------------------------------------------------
-- HELPER FUNCTIONS
--------------------------------------------------

local function log(msg)
    print(msg)
end


local function findAdminUser()

    local users = api.get("/users")

    if type(users) ~= "table" then
        error("Could not retrieve user list from /users")
    end

    log("Searching for admin user...")

    for _, user in ipairs(users) do

        local name =
            user.name or
            user.username or
            user.login or
            ""

        log(
            "  User ID " ..
            tostring(user.id) ..
            " : " ..
            tostring(name)
        )

        if string.lower(tostring(name)) ==
           string.lower(ADMIN_USERNAME) then

            log("")
            log(
                "ADMIN FOUND: " ..
                tostring(name) ..
                " [ID " ..
                tostring(user.id) ..
                "]"
            )

            return user.id
        end
    end

    return nil
end


--------------------------------------------------
-- MAIN
--------------------------------------------------

log("==============================================")
log(" Z-BOX UNAVAILABLE NOTIFICATION CONFIGURATION")
log("==============================================")
log("")

--------------------------------------------------
-- Find admin
--------------------------------------------------

local adminId = findAdminUser()

if not adminId then
    error(
        "Could not find a user named '" ..
        ADMIN_USERNAME ..
        "'. No changes were made."
    )
end

log("")
log("Using admin user ID: " .. tostring(adminId))
log("")


--------------------------------------------------
-- Get devices
--------------------------------------------------

local devices = api.get("/devices?visible=true")

if type(devices) ~= "table" then
    error("Could not retrieve device list.")
end


--------------------------------------------------
-- Counters
--------------------------------------------------

local changed       = 0
local alreadySet    = 0
local skipped       = 0
local errors        = 0


--------------------------------------------------
-- Process devices
--------------------------------------------------

for _, device in ipairs(devices) do

    local id   = device.id
    local name = device.name or ("Device " .. tostring(id))

    log("----------------------------------------------")
    log(
        "Checking: " ..
        tostring(name) ..
        " [ID " ..
        tostring(id) ..
        "]"
    )

    ------------------------------------------------
    -- Get notification definitions
    ------------------------------------------------

    local notificationData =
        api.get("/deviceNotifications/v1/" .. tostring(id))

    if type(notificationData) ~= "table" then

        log("  ERROR: Could not read notification settings.")
        errors = errors + 1

    else

        ------------------------------------------------
        -- Depending on firmware/API response,
        -- notifications may either be returned directly
        -- or inside a notifications table.
        ------------------------------------------------

        local notifications

        if notificationData.notifications then
            notifications = notificationData.notifications
        else
            notifications = notificationData
        end

        local unavailable = nil

        ------------------------------------------------
        -- Find Unavailable notification
        ------------------------------------------------

        for _, notification in ipairs(notifications) do

            if notification.type == "Unavailable" then
                unavailable = notification
                break
            end

        end


        ------------------------------------------------
        -- Device does not support this notification
        ------------------------------------------------

        if not unavailable then

            log("  SKIPPED: No Unavailable notification.")
            skipped = skipped + 1

        else

            ------------------------------------------------
            -- Determine whether it already matches
            ------------------------------------------------

            local correctActive =
                unavailable.active == true

            local correctInterval =
                unavailable.interval and
                unavailable.interval.type == "once"

            local hasEmail = false
            local hasPush  = false

            if unavailable.channels then

                for _, channel in ipairs(unavailable.channels) do

                    if channel == "Email" then
                        hasEmail = true
                    elseif channel == "Push" then
                        hasPush = true
                    end

                end

            end

            local correctUser = false

            if unavailable.users then

                for _, userId in ipairs(unavailable.users) do

                    if userId == adminId then
                        correctUser = true
                    end

                end

            end


            ------------------------------------------------
            -- Already configured
            ------------------------------------------------

            if correctActive
               and correctInterval
               and hasEmail
               and hasPush
               and correctUser then

                log("  ALREADY CONFIGURED")
                alreadySet = alreadySet + 1

            else

                ------------------------------------------------
                -- Show current state
                ------------------------------------------------

                log(
                    "  Current active: " ..
                    tostring(unavailable.active)
                )

                if unavailable.interval then
                    log(
                        "  Current interval: " ..
                        tostring(unavailable.interval.type)
                    )
                end

                ------------------------------------------------
                -- Apply desired configuration
                ------------------------------------------------

                unavailable.active = true

                unavailable.interval = {
                    type = "once"
                }

                unavailable.channels = {
                    "Email",
                    "Push"
                }

                unavailable.users = {
                    adminId
                }


                ------------------------------------------------
                -- Write it
                ------------------------------------------------

                if DRY_RUN then

                    log("  DRY RUN: Would update device.")

                else

                    local response, status =
                        api.put(
                            "/deviceNotifications/v1/" ..
                            tostring(id),
                            notifications
                        )

                    ------------------------------------------------
                    -- HC3 APIs sometimes don't return a useful
                    -- HTTP status to Lua, so accept nil/200/201.
                    ------------------------------------------------

                    if status == nil
                       or status == 200
                       or status == 201
                       or status == 204 then

                        log("  UPDATED SUCCESSFULLY")
                        changed = changed + 1

                    else

                        log(
                            "  ERROR updating device. HTTP status: " ..
                            tostring(status)
                        )

                        errors = errors + 1

                    end

                end

            end

        end

    end

end


--------------------------------------------------
-- Summary
--------------------------------------------------

log("")
log("==============================================")
log(" COMPLETE")
log("==============================================")
log("Changed:            " .. tostring(changed))
log("Already configured: " .. tostring(alreadySet))
log("Skipped:            " .. tostring(skipped))
log("Errors:             " .. tostring(errors))

if DRY_RUN then
    log("")
    log("*** DRY RUN MODE - NOTHING WAS CHANGED ***")
end
