<?xml version="1.0"?>

<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="clipboard::new.new_clipboard">
      <querytext>

select clipboard__new(:clipboard_id, :owner_id, :title, :package_id, now(), :creation_user_id, :peeraddr, :context)

      </querytext>
</fullquery>

<fullquery name="clipboard::delete.delete_clipboard">
      <querytext>

select clipboard__delete(:clipboard_id)

      </querytext>
</fullquery>

<fullquery name="clipboard::attach.map_object">      
      <querytext>

    INSERT into clipboard_object_map(clipboard_id, object_id, clipped_on)
    SELECT :clipboard_id, :object_id, now()
     WHERE acs_permission__permission_p(:clipboard_id, :user_id, 'write') = 't'

      </querytext>
</fullquery>

<fullquery name="clipboard::remove.unmap_object">      
      <querytext>

    DELETE FROM clipboard_object_map
     WHERE acs_permission__permission_p(:clipboard_id, :user_id, 'write') = 't'
       and clipboard_id = :clipboard_id
       and object_id = :object_id
      </querytext>
</fullquery>


</queryset>
