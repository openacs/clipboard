# /packages/cop-ui/www/clipboard/delete.tcl
ad_page_contract {
    delete a clipboard.

    @author Jeff Davis <davis@xarg.net>
    @creation-date 11/2/2003
    @cvs-id $Id$
} {
    clipboard_id:integer,notnull
}


permission::require_permission -object_id $clipboard_id -privilege delete

clipboard::delete -clipboard_id $clipboard_id

ad_returnredirect ./
