$(document).on("turbolinks:load", function() {
  var point = {
    x: null,
    y: null
  };


  $('#trainee-types-chart').highcharts({
    chart: {
      plotBackgroundColor: null,
      plotBorderWidth: null,
      plotShadow: false,
      type: 'pie'
    },
    title: false,
    plotOptions: {
      pie: {
        allowPointSelect: true,
        cursor: 'pointer',
        dataLabels: {
          enabled: false
        },
        showInLegend: true
      }
    },
    series: [{
      name: 'Brands',
      colorByPoint: true,
      data: eval("(" + $('#trainee-types-chart').data('trainee-types').replace(/:name=>/g, "name:").replace(/:y=>/g, "y:") + ")")
    }]
  });

  var locations_chart = new Highcharts.Chart({
    chart: {
      renderTo: 'locations-chart'
    },
    title: false,
    xAxis: {
      categories: $('#locations-chart').data('locations'),
      crosshair: true
    },
    yAxis: {
      min: 0,
      title: {
        text: 'Rainfall (mm)'
      }
    },
    tooltip: {
      headerFormat: '<span style="font-size:10px">{point.key}</span><table>',
      pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' +
        '<td style="padding:0"><b>{point.y:.1f} mm</b></td></tr>',
      footerFormat: '</table>',
      shared: true,
      useHTML: true
    },
    plotOptions: {
      column: {
        pointPadding: 0.2,
        borderWidth: 0
      }
    },
    series: [{
      type: 'column',
      name: 'Tokyo',
      data: $('#locations-chart').data('trainees')
    }]
  });

  if (typeof localStorage.locations_chart_data === typeof undefined) {
    var data = []
    for (i = 0; i < locations_chart.series[0].data.length; i++) {
      data.push({x: locations_chart.series[0].data[i].x, y: locations_chart.series[0].data[i].y});
    }

    localStorage.setItem("locations_chart_data", JSON.stringify(data));
  }

  $.each($('[id^="location-select-"]'), function (index, value){
    $(value).click(function () {
      var data = [];
      var data_points = JSON.parse(localStorage.locations_chart_data);

      if ($(this).hasClass('checked')) {
        var categories = [];
        $(this).removeClass('checked');
        $(this).css('color', 'black');

        for (i = 0; i < data_points.length; i++) {
          if (!$('#location-select-' + i).hasClass('checked')) {
            categories.push($('#locations-chart').data('locations')[i]);
            data.push([$('#locations-chart').data('locations')[i], data_points[i].y]);
          }
        }
        locations_chart.xAxis[0].setCategories(categories);
      } else {
        var no = $('#locations-chart').data('locations').indexOf($(this).find('.location-name').text());
        $(this).addClass('checked');
        $(this).css('color', 'gray');

        locations_chart.xAxis[0].setCategories($('#locations-chart').data('locations'), false);

        for (i = 0; i < data_points.length; i++) {
          if (i !== no && !$('#location-select-' + i).hasClass('checked')) {
            data.push([data_points[i].x, data_points[i].y]);
          }
        }
      }
      locations_chart.series[0].setData(data);
    });
  });
});
