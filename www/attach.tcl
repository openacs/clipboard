# /packages/cop-ui/www/clipboard/attach.tcl
ad_page_contract {
    Attach an object to one of your clipboards
    Requires registration.

    @author Jeff Davis davis@xarg.net
    @creation-date 10/30/2003
    @cvs-id $Id$
} {
    object_id:integer,notnull
    clipboard_id:integer,notnull
}

set user_id [auth::require_login]

if {$clipboard_id < 0} {
    ad_returnredirect "ae?object_id=$object_id"
    ad_script_abort
}

# If we got clipboard_id 0 then we need to create a "General" clipboard
if {$clipboard_id == 0} {
    set clipboard_id [clipboard::new -title "General"]
}

if {$clipboard_id > 0} { 
    clipboard::attach -clipboard_id $clipboard_id -object_id $object_id -user_id $user_id
}

# should redirect to the original object and preserve state...
ad_returnredirect [get_referrer]
