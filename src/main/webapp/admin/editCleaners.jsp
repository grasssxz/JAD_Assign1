<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<jsp:include page="/auth/AuthCheckAdmin.jsp" />

<%
Class.forName("com.mysql.cj.jdbc.Driver");
String connURL =
"jdbc:mysql://localhost:3306/jad_assign1"
+ "?user=root"
+ "&password=1G9r5a6c1E**"
+ "&serverTimezone=UTC"
+ "&useSSL=false"
+ "&allowPublicKeyRetrieval=true";
Connection conn = DriverManager.getConnection(connURL);

String ctx = request.getContextPath();
String message = null;
String action = request.getParameter("action");

/* ===============================
   LOAD ALL CLEANING TYPES (for checkboxes)
================================*/
PreparedStatement psTypes = conn.prepareStatement(
  "SELECT id, name FROM cleaning_type ORDER BY id"
);
ResultSet rsTypes = psTypes.executeQuery();

// We'll store types in memory so we can reuse later
java.util.List<Integer> typeIds = new java.util.ArrayList<>();
java.util.List<String> typeNames = new java.util.ArrayList<>();
while (rsTypes.next()){
  typeIds.add(rsTypes.getInt("id"));
  typeNames.add(rsTypes.getString("name"));
}
rsTypes.close();
psTypes.close();

/* ===============================
   HANDLE ACTIONS
================================*/

// ADD cleaner
if ("addCleaner".equals(action)) {
    String name = request.getParameter("name");
    String profileUrl = request.getParameter("profile_url");
    double basePay = Double.parseDouble(request.getParameter("base_hourly_pay"));
    String race = request.getParameter("race");
    String lang = request.getParameter("language");
    int years = Integer.parseInt(request.getParameter("years_experience"));
    int minHours = Integer.parseInt(request.getParameter("min_work_hours"));

    PreparedStatement psAdd = conn.prepareStatement(
      "INSERT INTO cleaner (name, profile_url, base_hourly_pay, race, language, years_experience, min_work_hours) " +
      "VALUES (?, ?, ?, ?, ?, ?, ?)", Statement.RETURN_GENERATED_KEYS
    );
    psAdd.setString(1, name);
    psAdd.setString(2, profileUrl);
    psAdd.setDouble(3, basePay);
    psAdd.setString(4, race);
    psAdd.setString(5, lang);
    psAdd.setInt(6, years);
    psAdd.setInt(7, minHours);
    psAdd.executeUpdate();

    int newCleanerId = -1;
    ResultSet rsKey = psAdd.getGeneratedKeys();
    if (rsKey.next()) newCleanerId = rsKey.getInt(1);
    rsKey.close();
    psAdd.close();

    // insert mappings
    if (newCleanerId > 0) {
        String[] selectedTypes = request.getParameterValues("typeIds");
        if (selectedTypes != null) {
            PreparedStatement psMap = conn.prepareStatement(
              "INSERT INTO cleaner_cleaning_type (cleaner_id, cleaning_type_id) VALUES (?, ?)"
            );
            for (String t : selectedTypes) {
                psMap.setInt(1, newCleanerId);
                psMap.setInt(2, Integer.parseInt(t));
                psMap.addBatch();
            }
            psMap.executeBatch();
            psMap.close();
        }
    }
    message = "Cleaner added.";
}

// UPDATE cleaner
if ("updateCleaner".equals(action)) {
    int cleanerId = Integer.parseInt(request.getParameter("id"));
    String name = request.getParameter("name");
    String profileUrl = request.getParameter("profile_url");
    double basePay = Double.parseDouble(request.getParameter("base_hourly_pay"));
    String race = request.getParameter("race");
    String lang = request.getParameter("language");
    int years = Integer.parseInt(request.getParameter("years_experience"));
    int minHours = Integer.parseInt(request.getParameter("min_work_hours"));

    PreparedStatement psUp = conn.prepareStatement(
      "UPDATE cleaner SET name=?, profile_url=?, base_hourly_pay=?, race=?, language=?, years_experience=?, min_work_hours=? " +
      "WHERE id=?"
    );
    psUp.setString(1, name);
    psUp.setString(2, profileUrl);
    psUp.setDouble(3, basePay);
    psUp.setString(4, race);
    psUp.setString(5, lang);
    psUp.setInt(6, years);
    psUp.setInt(7, minHours);
    psUp.setInt(8, cleanerId);
    psUp.executeUpdate();
    psUp.close();

    // reset mappings
    PreparedStatement psDelMap = conn.prepareStatement(
      "DELETE FROM cleaner_cleaning_type WHERE cleaner_id=?"
    );
    psDelMap.setInt(1, cleanerId);
    psDelMap.executeUpdate();
    psDelMap.close();

    String[] selectedTypes = request.getParameterValues("typeIds_" + cleanerId);
    if (selectedTypes != null) {
        PreparedStatement psMap = conn.prepareStatement(
          "INSERT INTO cleaner_cleaning_type (cleaner_id, cleaning_type_id) VALUES (?, ?)"
        );
        for (String t : selectedTypes) {
            psMap.setInt(1, cleanerId);
            psMap.setInt(2, Integer.parseInt(t));
            psMap.addBatch();
        }
        psMap.executeBatch();
        psMap.close();
    }

    message = "Cleaner updated.";
}

// DELETE cleaner
if ("deleteCleaner".equals(action)) {
    int cleanerId = Integer.parseInt(request.getParameter("id"));
    try {
        // delete mappings first
        PreparedStatement psDelMap = conn.prepareStatement(
          "DELETE FROM cleaner_cleaning_type WHERE cleaner_id=?"
        );
        psDelMap.setInt(1, cleanerId);
        psDelMap.executeUpdate();
        psDelMap.close();

        // delete reviews first
        PreparedStatement psDelRev = conn.prepareStatement(
          "DELETE FROM cleaning_review WHERE cleaner_id=?"
        );
        psDelRev.setInt(1, cleanerId);
        psDelRev.executeUpdate();
        psDelRev.close();

        // now delete cleaner
        PreparedStatement psDel = conn.prepareStatement(
          "DELETE FROM cleaner WHERE id=?"
        );
        psDel.setInt(1, cleanerId);
        psDel.executeUpdate();
        psDel.close();

        message = "Cleaner deleted.";
    } catch (SQLException e) {
        message = "Cannot delete cleaner (maybe has bookings). Remove bookings first.";
    }
}

/* ===============================
   LOAD CLEANERS
================================*/
PreparedStatement psCleaners = conn.prepareStatement(
  "SELECT * FROM cleaner ORDER BY id"
);
ResultSet rsCleaners = psCleaners.executeQuery();
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Edit Cleaners</title>
<style>
  body{font-family:Arial;padding:20px;background:#f6f7fb}
  h1{margin-top:0}
  a{color:#4b5bd6;text-decoration:none}
  .msg{margin:10px 0;color:#d13b3b;font-weight:600}

  .box{
    background:#fff;padding:16px;border-radius:12px;
    box-shadow:0 2px 8px rgba(0,0,0,.08);width:520px;margin-bottom:20px;
  }

  input[type=text], input[type=number]{
    width:95%;padding:8px;margin:5px 0
  }

  .types{
    display:flex;flex-wrap:wrap;gap:8px;margin:6px 0 10px
  }

  button{
    background:#7f9cf5;color:#fff;border:0;padding:7px 12px;border-radius:6px;cursor:pointer
  }
  button:hover{background:#5e7ce0}
  .danger{background:#e15858}
  .danger:hover{background:#c14141}

  table{width:98%;border-collapse:collapse;background:#fff;border-radius:10px;overflow:hidden}
  th,td{border:1px solid #eee;padding:10px;vertical-align:top}
  th{background:#eef0ff}
  
  /* make labels behave nicely */
label{
  font-weight:600;
  font-size:14px;
  margin-top:6px;
  display:block;            /* ensures label always on its own line */
}

/* grid container for each cleaner form */
.form-grid{
  display:grid;
  grid-template-columns: 140px 1fr;  /* left = label, right = input */
  gap:8px 12px;
  align-items:center;
}

/* inputs full width of right column */
.form-grid input[type=text],
.form-grid input[type=number]{
  width:100%;
  padding:8px;
  border:1px solid #ccc;
  border-radius:6px;
  box-sizing:border-box;
}

/* supports checkboxes area spans full width */
.form-grid .types{
  grid-column: 1 / -1;
  margin-top:6px;
  display:flex;
  flex-wrap:wrap;
  gap:10px;
}

/* tighten table look */
table td{
  vertical-align:top;
}

/* make save/delete column not huge */
.actions{
  white-space:nowrap;
  width:120px;
}
  
</style>
</head>
<body>

<h1>Edit Cleaners</h1>

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
  <h3>Add New Cleaner</h3>
  <form method="post" action="editCleaners.jsp">
    <input type="hidden" name="action" value="addCleaner">

    <label>Name</label>
    <input type="text" name="name" required>

    <label>Profile image filename (e.g. quin.jpg)</label>
    <input type="text" name="profile_url">

    <label>Base Hourly Pay (S$)</label>
    <input type="number" step="0.1" name="base_hourly_pay" required>

    <label>Race</label>
    <input type="text" name="race">

    <label>Language</label>
    <input type="text" name="language">
    <label>Years Experience</label>
    <input type="number" name="years_experience" value="0">

    <label>Min Work Hours</label>
    <input type="number" name="min_work_hours" value="1">

    <label>Cleaning Types This Cleaner Supports:</label>
    <div class="types">
      <% for(int i=0;i<typeIds.size();i++){ %>
        <label>
          <input type="checkbox" name="typeIds" value="<%= typeIds.get(i) %>">
          <%= typeNames.get(i) %>
        </label>
      <% } %>
    </div>

    <button type="submit">Add Cleaner</button>
  </form>
</div>

<h3>Existing Cleaners</h3>

<table>
<tr>
  <th>ID</th>
  <th>Cleaner Details + Types</th>
  <th>Save</th>
  <th>Delete</th>
</tr>

<%
while(rsCleaners.next()){
  int id = rsCleaners.getInt("id");
  String nm = rsCleaners.getString("name");
  String purl = rsCleaners.getString("profile_url");
  double pay = rsCleaners.getDouble("base_hourly_pay");
  String race = rsCleaners.getString("race");
  String lang = rsCleaners.getString("language");
  int years = rsCleaners.getInt("years_experience");
  int minH = rsCleaners.getInt("min_work_hours");

  // get current mappings
  PreparedStatement psMap = conn.prepareStatement(
    "SELECT cleaning_type_id FROM cleaner_cleaning_type WHERE cleaner_id=?"
  );
  psMap.setInt(1, id);
  ResultSet rsMap = psMap.executeQuery();
  java.util.Set<Integer> mapped = new java.util.HashSet<>();
  while(rsMap.next()) mapped.add(rsMap.getInt(1));
  rsMap.close(); psMap.close();
%>

<tr>
  <td><%= id %></td>

  <td>
  <form method="post" action="editCleaners.jsp">

    <input type="hidden" name="action" value="updateCleaner">
    <input type="hidden" name="id" value="<%= id %>">

    <div class="form-grid">
      <label>Name</label>
      <input type="text" name="name" value="<%= nm %>" required>

      <label>Profile URL</label>
      <input type="text" name="profile_url" value="<%= purl %>">

      <label>Base Pay (S$)</label>
      <input type="number" step="0.01" name="base_hourly_pay" value="<%= pay %>" required>

      <label>Race</label>
      <input type="text" name="race" value="<%= race %>">

      <label>Language</label>
      <input type="text" name="language" value="<%= lang %>">

      <label>Years Experience</label>
      <input type="number" name="years_experience" value="<%= years %>">

      <label>Min Work Hours</label>
      <input type="number" name="min_work_hours" value="<%= minH %>">

      <label>Supports</label>
      <div class="types">
        <% for(int i=0;i<typeIds.size();i++){
             int tId = typeIds.get(i);
        %>
          <label>
            <input type="checkbox"
                   name="typeIds_<%= id %>"
                   value="<%= tId %>"
                   <%= mapped.contains(tId) ? "checked" : "" %>>
            <%= typeNames.get(i) %>
          </label>
        <% } %>
      </div>
    </div>
 
  </td>

  <td>
      <button type="submit">Save</button>
    </form>
  </td>

  <td>
    <form method="post" action="editCleaners.jsp" onsubmit="return confirm('Delete this cleaner?');">
      <input type="hidden" name="action" value="deleteCleaner">
      <input type="hidden" name="id" value="<%= id %>">
      <button class="danger">Delete</button>
    </form>
  </td>
</tr>

<% } %>
</table>

<%
rsCleaners.close();
psCleaners.close();
conn.close();
%>
</body>
</html>
