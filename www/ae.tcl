# /packages/cop-ui/www/clipboard/ae.tcl
ad_page_contract {
    add/edit an object clipboard and optionally attach an 
    object at the same time.

    @author Jeff Davis davis@xarg.net
    @creation-date 10/30/2003
    @cvs-id $Id$
} {
    clipboard_id:optional
    {object_id:integer,optional {}}
}

set user_id [auth::require_login]

ad_form -name clip_ae -export {object_id} -form {
    clipboard_id:key(acs_object_id_seq)
    {title:text(text)             {label "Clipboard name"}
        {html {size 60}}}
} -select_query {
    select title from acs_objects where object_id = :clipboard_id and object_type = 'clipboard'
} -validate {
    {title
        {![string is space $title]} 
        "You must provide a name for the clipboard"
    }
} -new_data {
    clipboard::new -title $title
} -edit_data {
    set peeraddr [ad_conn peeraddr]
    permission::require_permission -object_id $clipboard_id -privilege admin
    db_dml do_update {
        UPDATE acs_objects 
           SET title = :title, last_modified = now(), modifying_user = :user_id, modifying_ip = :peeraddr
         WHERE object_id = :clipboard_id and object_type = 'clipboard'
    }
} -after_submit {
    if {![empty_string_p $object_id]} { 
        ad_returnredirect "attach?[export_vars -url {object_id clipboard_id}]"
    } else { 
        ad_returnredirect ./
    }
    ad_script_abort
}
