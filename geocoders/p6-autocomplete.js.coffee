class P6AutoComplete
  constructor: (input, options) ->
    window.p6AutoComplete = this
    @geoCoder = new google.maps.Geocoder()
    @place =
      existed_item: null
      formatted_address: ""
      address_components: []
      geometry:
        location: []
    @input = $(input)
    @input.bind()
    @options = options
    @completerOptions = options.completerOptions
    @setAutoComplete()

  setAutoComplete: ->
    @input.autocomplete( {
      source: (request, response) ->
        if p6AutoComplete.completerOptions && p6AutoComplete.completerOptions.only == 'google'
          search = { address: request.term }
          results = []
          p6AutoComplete.geoCoder.geocode search, (googleResults, status) ->
            if status == google.maps.GeocoderStatus.OK
              $.each googleResults, (index, item) ->
                validItem = {
                  latitude: item.geometry.location.ob,
                  longitude: item.geometry.location.pb,
                  title: item.formatted_address,
                  address: item.formatted_address,
                  address_components: item.address_components
                }
                results.push(validItem)
            response(results)
        else
          $.getJSON( "/admin/locations/search.json", {
            term: request.term
          }).done (data) ->
            results = []
            $.extend true, results, data
            $.each results, (index, item) ->
              item.title = item.address if !item.title
              item.existed_item = item
            search = { address: request.term }
            p6AutoComplete.geoCoder.geocode search, (googleResults, status) ->
              if status == google.maps.GeocoderStatus.OK
                $.each googleResults, (index, item) ->
                  validItem = {
                    latitude: item.geometry.location.ob,
                    longitude: item.geometry.location.pb,
                    title: item.formatted_address,
                    address: item.formatted_address,
                    address_components: item.address_components
                  }
                  results.push(validItem)
              response(results)
      minLength: 1,
      select: ( event, ui ) ->
        p6AutoComplete.input.val(ui.item.title)
        p6AutoComplete.setCurrentPlace(ui.item)
        google.maps.event.trigger(p6AutoComplete, "place_changed")
        return false
      }).data( "ui-autocomplete" )._renderItem = ( ul, item ) ->
        item.title ?= ''
        title_label = if item.title == '' then '' else "<strong>#{item.title}</strong><br/>"
        label = "#{title_label}#{item.address}"
        return $( "<li/>" ).data( "item.autocomplete", item ).append( "<a>"+label+"</a>" ).appendTo( ul )
  setCurrentPlace: (item) ->
    formatted_address = item.title ?= ''
    formatted_address = if formatted_address == '--' then '' else formatted_address
    $('#location_id').val(item.id)
    location = new google.maps.LatLng( item.latitude, item.longitude )
    $.extend @place, {
      existed_item: item.existed_item
      formatted_address: formatted_address
      address_components: item.address_components
      geometry:
        location: location
    }
  getPlace: ->
    @place

window.P6AutoComplete = P6AutoComplete