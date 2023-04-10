SET SERVEROUTPUT ON 
DECLARE
   CURSOR dev_header_cur
   IS
      SELECT *
        FROM apps.wsh_delivery_details
       WHERE delivery_detail_id IN
                (50550142); -- Provide delivery_detail_id

   l_index                     NUMBER;
   l_msg_return                NUMBER;
   x_return_status             VARCHAR2 (1);
   x_msg_count                 NUMBER;
   x_msg_data                  VARCHAR2 (2000);
   l_changedattributetabtype   WSH_DELIVERY_DETAILS_PUB.changedattributetabtype;
   l_file_name                 VARCHAR2 (32767);
   l_return_status             VARCHAR2 (32767);
   l_msg_data                  VARCHAR2 (32767);
   l_msg_count                 NUMBER;
BEGIN

   fnd_global.APPS_INITIALIZE (19282, 21623, 660); -- Provide user_id, resp_id and appl_id to initialize

   fnd_profile.put ('WSH_DEBUG_MODULE', '%');
   fnd_profile.put ('WSH_DEBUG_LEVEL', WSH_DEBUG_SV.C_STMT_LEVEL);
   DBMS_OUTPUT.PUT_LINE ('Start');
   wsh_debug_sv.start_debugger (l_file_name,
                                l_return_status,
                                l_msg_data,
                                l_msg_count);
   l_index := 0;

   FOR dev_header_rec IN dev_header_cur
   LOOP
      l_index := L_index + 1;

      l_changedattributetabtype (l_index).delivery_detail_id    := Dev_header_rec.delivery_detail_id;
      l_changedattributetabtype (l_index).subinventory          := 'DISPONIBLE'; -- Provide subinventory to update
      l_changedattributetabtype (l_index).shipped_quantity      := 3;
   END LOOP;

   WSH_DELIVERY_DETAILS_PUB.Update_Shipping_Attributes (
                      p_api_version_number   => 1.0,
                      p_init_msg_list        => FND_API.G_FALSE,
                      p_commit               => FND_API.G_FALSE,
                      x_return_status        => X_return_status,
                      x_msg_count            => X_msg_count,
                      x_msg_data             => X_msg_data,
                      p_changed_attributes   => l_changedattributetabtype,
                      p_source_code          => 'OE');

   COMMIT;

   IF x_return_status <> fnd_api.G_RET_STS_SUCCESS
   THEN
      FOR i IN 1 .. x_msg_count
      LOOP
         fnd_msg_pub.get (p_msg_index       => I,
                          P_encoded         => 'F',
                          P_data            => X_msg_data,
                          P_msg_index_out   => l_msg_return);
         DBMS_OUTPUT.PUT_LINE (x_msg_data);
      END LOOP;
   ELSE
      DBMS_OUTPUT.PUT_LINE ('S');
   END IF;
END;
