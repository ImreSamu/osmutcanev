<!DOCTYPE html>
<html>

<!-- Jquery -->
<link rel="stylesheet"    href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" type="text/css" />
<script type="text/javascript" src="https://code.jquery.com/jquery-1.12.3.js"></script>
<!-- DataTables -->
<link rel="stylesheet" href="https://cdn.datatables.net/1.10.12/css/jquery.dataTables.min.css" type="text/css"/>
<script type="text/javascript" src="https://cdn.datatables.net/1.10.12/js/jquery.dataTables.min.js"></script>    
<!-- Fixedheader -->
<link rel="stylesheet" href="https://cdn.datatables.net/fixedheader/3.1.2/css/fixedHeader.dataTables.min.css" type="text/css"/>                            
<script type="text/javascript" src="https://cdn.datatables.net/fixedheader/3.1.2/js/dataTables.fixedHeader.min.js"></script>
                    
<!-- colReorder -->                                        
<link rel="stylesheet" href="https://cdn.datatables.net/1.10.12/js/jquery.dataTables.min.js" type="text/css"/> 
<script type="text/javascript" src="https://cdn.datatables.net/colreorder/1.3.2/js/dataTables.colReorder.min.js"></script>

                                       
<script type="text/javascript" class="init">
      $(document).ready(function() {
         $('#example').DataTable( {
             fixedHeader: true,
             colReorder: true,
             "lengthMenu": [[ -1, 30, 20, 10 ], [ "All", 30, 20, 10 ]]
              
         } );
      } );
</script>

<head><title>   Street name comparisions  </title></head>
<body>    

    <table style="width: 1146px;" border="0">
      <tbody>
        <tr align="center">
          <td style="width: 278.617px; height: 19px;">datafile:  LastOSMTimestamp: xxxxxxxxxxx </td>
        </tr>
      </tbody>
    </table>

<table id="example" class="display" cellspacing="0" width="100%">
<thead>
 <tr>
                <th>Település</th>
                <th>OSM utcanév lefedettségi%</th>
                <th>Egyező utcanév db</th>
                <th>Hasonló utcanév db</th>
                <th>OSM-ből hiányzó utcanév db</th>
                <th>_db_bazis </th>    
                <th>_db_nincs_hasonlo_baz</th>                
 </tr>
</thead>
<tbody>
{{range .}}<tr>
 <td><a href="/reports/telepulesek2/{{.telepules}}.html">{{.telepules}}</a></td>
 <td>{{.osm_allapot_szazalek}}</td>
 <td>{{._db_egyezo}}</td>
 <td>{{._db_hasonlo}}</td>
 <td>{{._db_nincs_hasonlo_osm}}</td> 
 <td>{{._db_bazis}}</td>
 <td>{{._db_nincs_hasonlo_baz}}</td>
</tr>
{{end}}
</tbody>
</table>
  
   
</body>
</html>


