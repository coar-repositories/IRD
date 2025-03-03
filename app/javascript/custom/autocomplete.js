$('document').ready(function () {
    $('#autocomplete_system_owner').autocomplete({
        source: '/organisations/autocomplete',
        select: function (event, ui) {
            $('#system_owner_id').val(ui.item.value);
            $('#autocomplete_system_owner').val(ui.item.label);
            return false;
        },
    });

    // $('#autocomplete_agency_user').autocomplete({
    //     source: '/users/autocomplete',
    //     select: function (event, ui) {
    //         $('#agency_user_id').val(ui.item.value);
    //         $('#autocomplete_agency_user').val(ui.item.label);
    //         return false;
    //     },
    // });
    //
    // $('#autocomplete_authorisation_user').autocomplete({
    //     source: '/users/autocomplete',
    //     select: function (event, ui) {
    //         $('#authorisation_user_id').val(ui.item.value);
    //         $('#autocomplete_authorisation_user').val(ui.item.label);
    //         return false;
    //     },
    // });
    //
    // $('#authoriseExistingUserModal').on('shown.bs.modal', function () {
    //     $('#autocomplete_system_authorisation_user').autocomplete({
    //         source: '/users/autocomplete',
    //         select: function (event, ui) {
    //             $('#user_id').val(ui.item.value);
    //             $('#autocomplete_system_authorisation_user').val(ui.item.label);
    //             return false;
    //         },
    //     });
    // })
    //
    // $('#addExistingUserAsAgentModal').on('shown.bs.modal', function () {
    //     $('#autocomplete_organisation_agent').autocomplete({
    //         source: '/users/autocomplete',
    //         select: function (event, ui) {
    //             $('#user_id').val(ui.item.value);
    //             $('#autocomplete_organisation_agent').val(ui.item.label);
    //             return false;
    //         },
    //     });
    // })
});
