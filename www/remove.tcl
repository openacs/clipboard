# /packages/cop-ui/www/clipboard/remove.tcl
ad_page_contract {
    Detach an item from the clipboard.

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

clipboard::remove -user_id $user_id -clipboard_id $clipboard_id -object_id $object_id
ad_returnredirect [get_referrer]
