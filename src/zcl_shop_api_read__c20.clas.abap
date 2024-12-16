CLASS zcl_shop_api_read__c20 DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_shop_api_read__c20 IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.



    DATA:
      ls_entity_key    TYPE z_shop_api_scm__c20=>tys_online_shop_type,
      ls_business_data TYPE z_shop_api_scm__c20=>tys_online_shop_type,
      lo_http_client   TYPE REF TO if_web_http_client,
      lo_resource      TYPE REF TO /iwbep/if_cp_resource_entity,
      lo_client_proxy  TYPE REF TO /iwbep/if_cp_client_proxy,
      lo_request       TYPE REF TO /iwbep/if_cp_request_read,
      lo_response      TYPE REF TO /iwbep/if_cp_response_read.



    TRY.
        " Create http client
        DATA(lo_destination) = cl_http_destination_provider=>create_by_comm_arrangement(
                                                     comm_scenario  = 'Z_SHOP_SCENARIO_OUTBOUND__C20'
                                                     service_id     = 'Z_SHOP_API_READ_OBS__C20_REST' ).
        lo_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_destination ).
        lo_client_proxy = /iwbep/cl_cp_factory_remote=>create_v2_remote_proxy(
          EXPORTING
             is_proxy_model_key       = VALUE #( repository_id       = 'DEFAULT'
                                                 proxy_model_id      = 'Z_SHOP_API_SCM__C20'
                                                 proxy_model_version = '0001' )
            io_http_client             = lo_http_client
            iv_relative_service_root   = '' ).

        ASSERT lo_http_client IS BOUND.


        " Set entity key
        ls_entity_key = VALUE #(
                  order_uuid  = 'FF59992DCB461EEFAE88C09C14C2420F' ).

        " Navigate to the resource
        lo_resource = lo_client_proxy->create_resource_for_entity_set( 'ONLINE_SHOP' )->navigate_with_key( ls_entity_key ).

        " Execute the request and retrieve the business data
        lo_response = lo_resource->create_request_for_read( )->execute( ).
        lo_response->get_business_data( IMPORTING es_business_data = ls_business_data ).


        DATA lv_result TYPE String.
*        lv_result = |Order ID: { ls_business_data-order_id }, Ordered Item: { ls_business_data-cost_center }|.
        lv_result = |Order ID: { ls_business_data-order_id }, Ordered CostCentre: { ls_business_data-cost_center }|.
        response->set_text( lv_result ).

      CATCH /iwbep/cx_cp_remote INTO DATA(lx_remote).
        " Handle remote Exception
        " It contains details about the problems of your http(s) connection
        response->set_text( |Remote Error: { lx_remote->get_longtext(  ) }| ).

      CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
        " Handle Exception
        response->set_text( |Gateway Error: { lx_gateway->get_longtext(  ) }| ).
      CATCH cx_http_dest_provider_error INTO DATA(lx_destination).
        " Handle Exception
        response->set_text( |Destination Error: { lx_destination->get_longtext(  ) }| ).

      CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
        " Handle Exception
        response->set_text( |HTTP Client Error: { lx_web_http_client_error->get_longtext(  ) }| ).

    ENDTRY.

  ENDMETHOD.
ENDCLASS.
