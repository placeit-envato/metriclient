Class('SingleSiteStats')({
  prototype: {
    init: function(data) {
      this.data = data;
      //get template
      this.template = $('.single-site-stats-template').html();

      this.renderElement();
    },

    renderElement: function(){
      var singleSiteStats = this;
      //process template
      this.template = $( _.template(this.template, this.data.siteData) );
      
      //place centered spinner
      this.spinner = this.template.find('.spinner');
      $(new Spinner(spinnerOpts).spin(this.spinner[0]).el).css('left','50%');

      this.element = this.template;

      //query activity
      var query = '';

      query += apiUrl+'query?query={';
      query += '"time_start" : "'+ this.data.dateRange[0] +'", ';
      query += '"time_end"   : "'+ this.data.dateRange[1] +'", ';
      query += '"slices" : "'+ this.data.resolution +'", ';
      query += '"site_id" : "'+ this.data.siteData.id +'"';
      query += '}';

      $.get(query,function(data){
        singleSiteStats.parseData(data);
      });

    },

    parseData: function(data){
      var seriesValues = new Array();
      
      _.each(data, function(el, i){
        seriesValues.push( el.total );
      });

      var serieData = {
        pointStart: this.data.dateRange[0],
        pointInterval: this.data.resolution,
        data: seriesValues
      };

      this.renderChart( serieData );
    },

    renderChart: function(serieData){

      var highChartConfig = {
        chart: {
            renderTo: this.template.find('.activity-chart')[0],
            defaultSeriesType: 'area',
            height: 100,
            plotBorderColor: '#e3e6e8',
            plotBorderWidth: 0,
            plotBorderRadius: 2,
            backgroundColor: '',
            spacingLeft: 0,
            plotBackgroundColor: '#FFFFFF',
            marginTop: 0,
            marginBottom: 0,
            marginLeft: 0,
            zoomType: 'x,y'
        },

        credits: {
            enabled: false,
            style: {
                color: '#9fa2a5'
            }
        },

        title: {
            text: ''
        },

        legend: {
            align: 'left',
            floating: true,
            verticalAlign: 'top',
            borderWidth: 0,
            y: 3,
            x: 10,
            itemStyle: {
                fontSize: '11px',
                color: '#1E1E1E'
            }
        },

        yAxis: {
            title: {
                text: ''
            },
            gridLineColor: '#FAFAFA',
            opposite: true,
            labels: {
                align: 'right',
                style: {
                    color: '#333',
                    fontSize: 8
                },
                x: -10,
                y: 10
            }
        },

        xAxis: {
            type: 'datetime',
            tickPosition: 'inside',
            tickLength: 3,
            lineWidth: 0,
            maxZoom: 5 * 24 * 3600 * 1000, // 5 days
            tickInterval: 24 * 3600 * 1000, // 1 day
            labels: {
                formatter: function() {
                    return Highcharts.dateFormat('%e', this.value);
                },
                x: 0,
                y: -5,
                style: {
                    color: '#FFF',
                    fontSize: 8
                }
            }
        },

        plotOptions: {
            series: {
                marker: {
                    lineWidth: 1, // The border of each point (defaults to white)
                    radius: 3 // The thickness of each point
                },

                lineWidth: 2, // The thickness of the line between points
                shadow: false
            },
            area:{
              animation: false
            }
        },
        colors: [
            '#2f85ce', // orange
            '#4c97d7', // blue
            '#52d74c', // green
            '#e268de' // purple
        ],
        
        series: [{
            pointStart: serieData.pointStart.getTime(),
            pointInterval: 24 * 3600 * 1000,
            name: 'Actions',
            marker: {
                symbol: 'circle'
            },
            // Just some random data. Replace this with your own.
            data: serieData.data
        }]
      };

      //remove spinner
      this.spinner.remove();
      this.chart = new Highcharts.Chart( highChartConfig );

    } 
  }
});
