$(document).on('turbolinks:load', function() {
  if ($('meta[name=current-user]').attr('id').length > 0) {
    if (typeof localStorage.calendar_data === typeof undefined) {
      $.ajax({
        url: '/calendars.json',
        type: 'json',
        method: 'get',
        complete: function (data) {
          localStorage.setItem('calendar_data', JSON.stringify(data.responseJSON));
        }
      });
    }
  } else if (localStorage.calendar_data) {
    localStorage.removeItem('calendar_data');
  }

  $('#calendar').fullCalendar({
    theme: true,
    header: {
      left: 'prev,next today',
      center: 'title',
      right: 'month,agendaWeek,agendaDay,listMonth'
    },
    height: 'auto',
    navLinks: true,
    editable: true,
    eventLimit: true,
    businessHours: {
      dow: [1, 2, 3, 4, 5]
    },
    events: {
      url: '/calendars.json',
      error: function() {
        $('#script-warning').show();
      }
    },
    dayRender: function (date, cell){
      var dateObj = new Date(date);
      var event_array = JSON.parse(localStorage.calendar_data);
      var temp_date = new Date(event_array[event_array.length-1].end);
      if (dateObj.getDate() === temp_date.getDate()){
        cell.css('background', 'red');
      }
    },
    loading: function(bool) {
      $('#loading').toggle(bool);
    }
  });

  $('#tiny-calendar').fullCalendar({
    height: 'auto',
    theme: true,
    header: {
      left: 'prev,next',
      center: 'title',
      right: 'today'
    },
    dayRender: function (date, cell){
      var dateObj = new Date(date);
      var current = dateObj.getFullYear()+ '-' +
        (dateObj.getMonth() + 1 < 10 ? '0' : '') +(dateObj.getMonth() + 1) + '-' +
        (dateObj.getDate() < 10 ? '0':'') + dateObj.getDate();
      $.each(JSON.parse(localStorage.calendar_data), function (i, v){
        if (current === v.end) {
          cell.css('background', 'red');
        }
      });
    },
    editable: true,
    fixedWeekCount: false,

    dayClick: function (date, allDay, jsEvent, view) {
      var date2 = new Date(date);
      var selectDate = date2.getFullYear()+ '-' +
        (date2.getMonth() + 1 < 10 ? '0' : '') +(date2.getMonth() + 1) + '-' +
        (date2.getDate() < 10 ? '0' : '') + date2.getDate();
      var chil = '';
      $.each(JSON.parse(localStorage.calendar_data), function (i, v){
        if (selectDate === v.end) {
          chil += I18n.t("calendars.must_be_finished") + v.title + '<br/>';
          chil += "Task finished " + '<br/>';
          var arr = v.task_user.split('/');
          for(var i=0; i < arr.length; i++){
            chil += arr[i] + '<br/>';
          };
        }
      });
      $('#dialog').html(chil);
      $('#dialog').dialog('open');
    },
  });
  $('#dialog').dialog({
    autoOpen: false,
    height: 350,
    width: 500,
    header: 'Schedule',
    buttons: {
      OK: function () {
        $(this).dialog('close');
      }
    },
    close: function () {
    }
  });
});
