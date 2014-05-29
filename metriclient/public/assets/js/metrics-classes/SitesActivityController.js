Class('SitesActivityController')({
  prototype: {
    init: function(element) {
      var sitesActivityController = this;
      this.element = element;
      this.data = new Array();

      this.resolution = this.element.find('.date-resolution');
      this.sendButton = this.element.find('.send-query');
      this.timeControls = this.element.find('.time-controls');
      this.spinner = this.element.find('.spinner');
      // console.log(this.sendButton);
      this.dateRange = this.element.find('.date-range').val( Date.parse('t - 7 d').toString('dd MMM yyyy') +' - '+ Date.today().toString('dd MMM yyyy') );
      this.dateRange.daterangepicker({dateFormat:'dd M yy', onChange:function(){
          sitesActivityController.refreshSites();
        }
      });

      $(new Spinner(spinnerOpts).spin(this.spinner[0]).el);

      //get all sites
      $.get(apiUrl+'site_ids',function(data){
        sitesActivityController.data = data.sort();
        sitesActivityController.spinner.remove();
        sitesActivityController.timeControls.show();
        // sitesActivityController.renderSites();
      });

      this.bindEvents();
    },

    refreshSites: function(){
      


    },

    parseDates:function(){
      var dateValues = this.dateRange.val().split(' - ');
      dateValues[0] = Date.parse(dateValues[0]).set({hour: 00, minute: 00});
      dateValues[1] = Date.parse(dateValues[1]).set({hour: 23, minute: 59});
      return dateValues
    },

    bindEvents: function(){
      var sitesActivityController = this;

      this.sendButton.click(function(){
        window.stop();
        sitesActivityController.renderSites();
      });
      
    },

    renderSites: function(){
      var sitesActivityController = this;

      this.element.find('.sites-stats .stats-wrapper').remove();

      //parse site data to build string values
      var statsBuffer = $('<div class="stats-wrapper"></div>');
      var sites = new Array();
      
      _.each(this.data, function(id, i){
        var siteConfig = {
          siteData:{
            id: id
          },
          dateRange: sitesActivityController.parseDates(),
          resolution : sitesActivityController.resolution.val()
        };
        statsBuffer.append( new SingleSiteStats(siteConfig).element );
      });
      
      this.element.find('.sites-stats').append( statsBuffer );
      
      // var i = sites.length;
      // while(i--){
      //   statsBuffer.append( sites[i].element );
      // }

      // statsBuffer = statsBuffer.find('.single-site-stats');

      // statsBuffer.each(function(){
      //   $(this).data('api');
      // });


      // var i = sites.length;
      // while(i--){
      //   sites[i].renderChart();
      // }

    }
  }
});
