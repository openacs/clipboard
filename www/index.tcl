# /packages/cop-ui/www/clipboard/view.tcl
ad_page_contract {
    Display all the clipboards for the logged in user

    @author Jeff Davis (davis@xarg.net)
    @creation-date 11/12/2003
    @cvs-id $Id$
} {}


set user_id [auth::require_login]

if {$user_id > 0} { 
    clipboard::clipboards -count $user_id clipboards
}
