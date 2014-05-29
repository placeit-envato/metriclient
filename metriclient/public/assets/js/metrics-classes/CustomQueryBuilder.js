Class('CustomQueryBuilder')({
  prototype: {
    init: function(element, data) {
      this.element = element;
      
      //build sites autocomplete
      this.resolution = this.element.find('.date-resolution');
      this.siteId = this.element.find('.site-id');
      this.grid = this.element.find('.data-grid');
      this.dateRange = this.element.find('.date-range').val( Date.parse('t - 7 d').toString('dd MMM yyyy') +' - '+ Date.today().toString('dd MMM yyyy') );
      this.dateRange.daterangepicker({dateFormat:'dd M yy', onChange:function(){
          sitesActivityController.refreshSites();
        }
      });
      this.searchBtn = this.element.find('.send-query');

      this.bindEvents();

    },

    bindEvents:function(){
      var customQueryBuilder = this;

      this.searchBtn.click(function(){
        customQueryBuilder.sendQuery();
      });

    },

    sendQuery: function(){
      var customQueryBuilder = this;

      var data = {
        dateRange: this.parseDates(),
        resolution: this.resolution.val(),
        siteData: {
          id: this.siteId.val()
        }
      }

      //query activity
      var query = '';

      query += apiUrl+'query?query={';
      query += '"time_start" : "'+ data.dateRange[0] +'", ';
      query += '"time_end"   : "'+ data.dateRange[1] +'", ';
      query += '"slices" : "'+ data.resolution +'", ';
      query += '"site_id" : "'+ data.siteData.id +'"';
      query += '}';

      $.get(query,function(data){
        customQueryBuilder.parseData(data);
      });
      
      //this.parseData( [{"total":0,"events":[]},{"total":0,"events":[]},{"total":0,"events":[]},{"total":0,"events":[]},{"total":0,"events":[]},{"total":0,"events":[]},{"total":0,"events":[]},{"total":0,"events":[]},{"total":0,"events":[]},{"total":0,"events":[]},{"total":0,"events":[]},{"total":0,"events":[]},{"total":0,"events":[]},{"total":0,"events":[]},{"total":0,"events":[]},{"total":0,"events":[]},{"total":0,"events":[]},{"total":0,"events":[]},{"total":0,"events":[]},{"total":0,"events":[]},{"total":0,"events":[]},{"total":0,"events":[]},{"total":0,"events":[]},{"total":0,"events":[]},{"total":0,"events":[]},{"total":0,"events":[]},{"total":0,"events":[]},{"total":0,"events":[]},{"total":38,"events":[{"event":"AppStore:drag:app:install","count":1},{"event":"App:installed","count":1},{"event":"Dot:open","count":10},{"event":"Dot:change","count":22},{"event":"App:uninstalled","count":1},{"event":"App:entry:edit:cms","count":2},{"event":"imageEditorPanel:image:saved","count":1}]},{"total":0,"events":[]}] );
    },

    parseData: function(data){



      var gridDataRows = new Array();

      _.each(data, function(el, i){
        
        // var rowData = [];
        _.each(el.events, function(action, j){
          console.log('>>>>');
          console.log(action);
          var row = {id: i , cell:[ action.count, action.event ]};
          if(typeof action.siteId !== 'undefined')row.cell.push(action.siteId)
          gridDataRows.push(row);
        });
        // gridData.rows.push(rowData);

      });

      this.renderGrid( gridDataRows );
    },

    parseDates: function(){
      var dateValues = this.dateRange.val().split(' - ');
      dateValues[0] = Date.parse(dateValues[0]).set({hour: 00, minute: 00});
      dateValues[1] = Date.parse(dateValues[1]).set({hour: 23, minute: 59});
      return dateValues
    },

    renderGrid: function(gridData){
      console.log(gridData);
      var customQueryBuilder = this;

      var rowTemplate = '<tr><td>{{action}}</td><td>{{count}}</td></tr>';

      _.each(gridData, function(el, i){
        
        customQueryBuilder.grid.find('tbody').append( ''+rowTemplate.replace('{{action}}', el.cell[0]).replace('{{count}}', el.cell[1]) )

      });

      // this.grid.ingrid({
      //   height: 350,
      //   width: 800
      // });

      // this.element.find('.flexigrid').flexigrid({
      //   url: 'http://flexigrid.info/post2.php',
      //   dataType: 'json',
      //   colModel : [
      //     {display: 'Count', name : 'count', width : 200, sortable : true, align: 'left'},
      //     {display: 'Action', name : 'action', width : 200, sortable : true, align: 'left'}
      //   ],
      //   searchitems : [
      //     {display: 'Count', name : 'count', isdefault: true},
      //     {display: 'Action', name : 'action'}
      //   ],
      //   sortname: "siteId",
      //   sortorder: "asc",
      //   usepager: true,
      //   title: 'Actions',
      //   useRp: true,
      //   rp: 15,
      //   showTableToggleBtn: true,
      //   width: 700,
      //   height: 200
      // });

      // console.log(this.element.find('.flexigrid'));
      
    }
  }
});