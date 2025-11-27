<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<jsp:include page="/auth/AuthCheckAdmin.jsp" />

<%
Class.forName("com.mysql.cj.jdbc.Driver");
String connURL = "jdbc:mysql://localhost:3306/jad_assign1?user=root&paassword=1G9r5a6c1E**&serverTimezone=UTC";
Connection conn = DriverManager.getConnection(connURL);

String ctx = request.getContextPath();
String message = null;

String action = request.getParameter("action");

/* ===============================
   HANDLE ACTIONS
================================*/

if ("addType".equals(action)) {
    String name = request.getParameter("name");
    String incStr = request.getParameter("pay_increment");
    double inc = (incStr == null || incStr.isEmpty()) ? 0.0 : Double.parseDouble(incStr);

    String servicePic = request.getParameter("service_picture");
    String serviceLink = request.getParameter("service_link");

    if (servicePic != null && servicePic.trim().isEmpty()) servicePic = null;
    if (serviceLink == null || serviceLink.trim().isEmpty()) {
        serviceLink = "/Services/Cleaning/" + name.replace(" ", "") + ".jsp";
    }

    conn.setAutoCommit(false); // start transaction

    try {
        // 1) insert into cleaning_type
        PreparedStatement psAdd = conn.prepareStatement(
            "INSERT INTO cleaning_type (name, pay_increment) VALUES (?, ?)",
            Statement.RETURN_GENERATED_KEYS
        );
        psAdd.setString(1, name);
        psAdd.setDouble(2, inc);
        psAdd.executeUpdate();

        ResultSet keys = psAdd.getGeneratedKeys();
        int newTypeId = 0;
        if (keys.next()) newTypeId = keys.getInt(1);
        keys.close();
        psAdd.close();

        // 2) insert into service (category_id always 2)
        PreparedStatement psService = conn.prepareStatement(
            "INSERT INTO service (category_id, name, description, service_picture, service_link) " +
            "VALUES (2, ?, NULL, ?, ?)"
        );
        psService.setString(1, name);
        psService.setString(2, servicePic);
        psService.setString(3, serviceLink);
        psService.executeUpdate();
        psService.close();

        // 3) add mappings for ALL cleaners to this new type
        PreparedStatement psMap = conn.prepareStatement(
            "INSERT INTO cleaner_cleaning_type (cleaner_id, cleaning_type_id) " +
            "SELECT id, ? FROM cleaner"
        );
        psMap.setInt(1, newTypeId);
        psMap.executeUpdate();
        psMap.close();

        conn.commit();
        message = "Cleaning type added + service created + cleaners linked.";

    } catch (Exception e) {
        conn.rollback();
        message = "Add failed: " + e.getMessage();
    } finally {
        conn.setAutoCommit(true);
    }
}


/* ===============================
DELETE CLEANING TYPES
================================*/
if ("deleteType".equals(action)) {
    int typeId = Integer.parseInt(request.getParameter("id"));

    conn.setAutoCommit(false);

    try {
        // get type name first (so we can delete matching service row)
        String typeName = null;
        PreparedStatement psGet = conn.prepareStatement(
            "SELECT name FROM cleaning_type WHERE id=?"
        );
        psGet.setInt(1, typeId);
        ResultSet rGet = psGet.executeQuery();
        if (rGet.next()) typeName = rGet.getString("name");
        rGet.close(); psGet.close();

        // 1) remove mappings
        PreparedStatement psMap = conn.prepareStatement(
            "DELETE FROM cleaner_cleaning_type WHERE cleaning_type_id=?"
        );
        psMap.setInt(1, typeId);
        psMap.executeUpdate();
        psMap.close();

        // 2) remove reviews
        PreparedStatement psRev = conn.prepareStatement(
            "DELETE FROM cleaning_review WHERE cleaning_type_id=?"
        );
        psRev.setInt(1, typeId);
        psRev.executeUpdate();
        psRev.close();

        // 3) delete from cleaning_type
        PreparedStatement psDelType = conn.prepareStatement(
            "DELETE FROM cleaning_type WHERE id=?"
        );
        psDelType.setInt(1, typeId);
        psDelType.executeUpdate();
        psDelType.close();

        // 4) delete matching service row (category_id=2 + same name)
        if (typeName != null) {
            PreparedStatement psDelService = conn.prepareStatement(
                "DELETE FROM service WHERE category_id=2 AND name=?"
            );
            psDelService.setString(1, typeName);
            psDelService.executeUpdate();
            psDelService.close();
        }

        conn.commit();
        message = "Cleaning type + mappings + reviews + service deleted.";

    } catch (Exception e) {
        conn.rollback();
        message = "Delete failed: " + e.getMessage();
    } finally {
        conn.setAutoCommit(true);
    }
}

/* ===============================
LOAD CLEANING TYPES
================================*/
PreparedStatement psList = conn.prepareStatement(
 "SELECT id, name, pay_increment FROM cleaning_type ORDER BY id"
);
ResultSet rsList = psList.executeQuery();


%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Edit Services (Cleaning Types)</title>
<style>
  body{font-family:Arial;padding:20px;background:#f6f7fb}
  h1{margin-top:0}
  a{color:#4b5bd6;text-decoration:none}
  .msg{margin:10px 0;color:#d13b3b;font-weight:600}

  .box{
    background:#fff;padding:16px;border-radius:12px;
    box-shadow:0 2px 8px rgba(0,0,0,.08);width:420px;margin-bottom:20px;
  }
  input[type=text], input[type=number]{width:95%;padding:8px;margin:6px 0}
  button{
    background:#7f9cf5;color:#fff;border:0;padding:7px 12px;border-radius:6px;cursor:pointer
  }
  button:hover{background:#5e7ce0}
  .danger{background:#e15858}
  .danger:hover{background:#c14141}

  table{width:95%;border-collapse:collapse;background:#fff;border-radius:10px;overflow:hidden}
  th,td{border:1px solid #eee;padding:10px}
  th{background:#eef0ff}
</style>
</head>
<body>

<h1>Edit Services (Cleaning Types)</h1>


<!-- back to home page button -->
<a class="btn" 
   style="background:#64748b; color:white;"
   href="<%=request.getContextPath()%>/admin/admin_homePage.jsp">
    ← Back to Admin Home
</a>

<% if (message != null) { %>
  <div class="msg"><%= message %></div>
<% } %>

<div class="box">
  <h3>Add New Cleaning Type</h3>
  <form method="post" action="editCleaningService.jsp">
    <input type="hidden" name="action" value="addType">
    <label>Name</label>
    <input type="text" name="name" required>
    <label>Pay Increment (S$)</label>
    <input type="number" step="0.01" name="pay_increment" value="0">
    <button type="submit">Add</button>
  </form>
</div>

<h3>Existing Cleaning Types</h3>
<table>
  <tr>
    <th>ID</th>
    <th>Name</th>
    <th>Increment (S$)</th>
    <th>Save</th>
    <th>Delete Type</th>
  </tr>

<% while (rsList.next()) { 
     int id = rsList.getInt("id");
     String nm = rsList.getString("name");
     double inc = rsList.getDouble("pay_increment");
%>
  <tr>
    <td><%= id %></td>

    <td>
      <form method="post" action="editCleaningService.jsp">
        <input type="hidden" name="action" value="updateType">
        <input type="hidden" name="id" value="<%= id %>">
        <input type="text" name="name" value="<%= nm %>" required>
        <label>Service Picture Filename</label>
		<input type="text" name="service_picture" placeholder="e.g. springcleaning.png">
		<label>Service Link</label>
		<input type="text" name="service_link" placeholder="e.g. /Services/Cleaning/SpringCleaning.jsp"> 
    </td>

    <td>
        <input type="number" step="0.01" name="pay_increment" value="<%= inc %>" required>
    </td>

    <td>
        <button type="submit">Save</button>
      </form>
    </td>


    <td>
      <form method="post" action="editCleaningService.jsp" onsubmit="return confirm('Delete this cleaning type?');">
        <input type="hidden" name="action" value="deleteType">
        <input type="hidden" name="id" value="<%= id %>">
        <button class="danger">Delete Type</button>
      </form>

    </td>
  </tr>
<% } %>
</table>

<%
rsList.close();
psList.close();
conn.close();
%>
</body>
</html>
