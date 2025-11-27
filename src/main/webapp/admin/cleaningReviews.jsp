<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.sql.*" %>

<jsp:include page="/auth/AuthCheckAdmin.jsp" />

<%
String connURL =
"jdbc:mysql://localhost:3306/jad_assign1"
+ "?user=root"
+ "&password=1G9r5a6c1E**"
+ "&serverTimezone=UTC"
+ "&useSSL=false"
+ "&allowPublicKeyRetrieval=true";
Class.forName("com.mysql.cj.jdbc.Driver");

String action = request.getParameter("action");
String selectedTypeId = request.getParameter("cleaning_type_id");   // dropdown chosen type
String searchMember = request.getParameter("member_id");            // optional search
String deleteId = request.getParameter("id");

/* ===============================
   DELETE REVIEW
   keep filters after delete
================================*/
if ("delete".equals(action) && deleteId != null) {
    try (Connection connDel = DriverManager.getConnection(connURL);
         PreparedStatement psDel = connDel.prepareStatement(
             "DELETE FROM cleaning_review WHERE id=?"
         )) {
        psDel.setInt(1, Integer.parseInt(deleteId));
        psDel.executeUpdate();
    }

    // redirect back with same filters
    String redirectUrl = "cleaningReviews.jsp";
    if (selectedTypeId != null && !selectedTypeId.trim().isEmpty()) {
        redirectUrl += "?cleaning_type_id=" + selectedTypeId;
        if (searchMember != null && !searchMember.trim().isEmpty()) {
            redirectUrl += "&member_id=" + searchMember.trim();
        }
    }
    response.sendRedirect(redirectUrl);
    return;
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Cleaning Reviews</title>
<style>
body { font-family: Arial; padding: 20px; background: #f8f9ff; }
h2 { color: #4f46e5; margin-top: 10px; }
table { border-collapse: collapse; width: 100%; margin-top: 16px; background:#fff; }
th, td { padding: 10px; border: 1px solid #ddd; vertical-align: top; }
th { background: #eef; }
.btn-del {
  background: #e11d48; color: white; padding: 6px 10px;
  text-decoration:none; border-radius:6px; display:inline-block;
}
.btn-del:hover { background:#be123c; }
.controls {
  margin-top: 12px; padding: 12px; background:#fff; border-radius:8px;
  display:flex; gap:12px; align-items:center; flex-wrap:wrap;
}
select, input[type=text] { padding:6px; }
button {
  padding:6px 12px; background:#4f46e5; color:white;
  border:0; border-radius:6px; cursor:pointer;
}
.back-btn {
  display:inline-block; padding:8px 14px; margin-bottom:8px;
  background:#64748b; color:white; text-decoration:none; border-radius:6px;
}
.note { color:#666; font-size: 14px; }
</style>
</head>
<body>

<a href="<%=request.getContextPath()%>/admin/admin_homePage.jsp" class="back-btn">
  ← Back to Admin Home
</a>

<h2>Cleaning Type Reviews</h2>

<%
/* ===============================
   DROPDOWN: CLEANING TYPES
================================*/
try (Connection connType = DriverManager.getConnection(connURL);
     PreparedStatement psType = connType.prepareStatement(
         "SELECT id, name FROM cleaning_type ORDER BY name"
     );
     ResultSet rp = psType.executeQuery()) {
%>

<form class="controls" method="get" action="cleaningReviews.jsp">
  <label><b>Select Cleaning Type:</b></label>
  <select name="cleaning_type_id" required>
    <option value="">-- Choose Cleaning Type --</option>
    <%
      while (rp.next()) {
        String tid = rp.getString("id");
        String tname = rp.getString("name");
        String sel = tid.equals(selectedTypeId) ? "selected" : "";
    %>
      <option value="<%=tid%>" <%=sel%>><%=tid%> - <%=tname%></option>
    <%
      }
    %>
  </select>

  <label><b>Search Member ID:</b></label>
  <input type="text" name="member_id"
         value="<%= (searchMember!=null?searchMember:"") %>"
         placeholder="e.g. 3">

  <button type="submit">Show Reviews</button>

  <span class="note">* Choose cleaning type first, then optionally filter by member_id.</span>
</form>

<%
} catch (Exception e) {
  out.println("<p style='color:red'>Type load error: " + e.getMessage() + "</p>");
}
%>

<%
/* ===============================
   SHOW REVIEWS IF TYPE SELECTED
================================*/
if (selectedTypeId != null && !selectedTypeId.trim().isEmpty()) {

    String sql =
      "SELECT r.id AS review_id, r.member_id, r.review_text, r.created_at, " +
      "       ct.name AS cleaning_type_name, " +
      "       c.name AS cleaner_name " +
      "FROM cleaning_review r " +
      "JOIN cleaning_type ct ON r.cleaning_type_id = ct.id " +
      "JOIN cleaner c ON r.cleaner_id = c.id " +
      "WHERE ct.id = ? ";

    boolean hasMemberFilter = (searchMember != null && !searchMember.trim().isEmpty());
    if (hasMemberFilter) sql += " AND r.member_id = ? ";

    sql += " ORDER BY r.created_at DESC";

    try (Connection connList = DriverManager.getConnection(connURL);
         PreparedStatement ps = connList.prepareStatement(sql)) {

        ps.setInt(1, Integer.parseInt(selectedTypeId));
        if (hasMemberFilter) {
            ps.setInt(2, Integer.parseInt(searchMember.trim()));
        }

        try (ResultSet rs = ps.executeQuery()) {
%>

<table>
  <tr>
    <th>ID</th>
    <th>Member ID</th>
    <th>Cleaning Type</th>
    <th>Cleaner</th>
    <th>Review</th>
    <th>Created</th>
    <th>Action</th>
  </tr>

<%
boolean hasRows = false;
while (rs.next()) {
  hasRows = true;
%>
  <tr>
    <td><%= rs.getInt("review_id") %></td>
    <td><%= rs.getInt("member_id") %></td>
    <td><b><%= rs.getString("cleaning_type_name") %></b></td>
    <td><%= rs.getString("cleaner_name") %></td>
    <td><%= rs.getString("review_text") %></td>
    <td><%= rs.getTimestamp("created_at") %></td>
    <td>
      <a class="btn-del"
         onclick="return confirm('Delete this review?');"
         href="cleaningReviews.jsp?action=delete&id=<%=rs.getInt("review_id")%>&cleaning_type_id=<%=selectedTypeId%><%= hasMemberFilter ? "&member_id=" + searchMember.trim() : "" %>">
         Delete
      </a>
    </td>
  </tr>
<%
}
if (!hasRows) {
%>
  <tr>
    <td colspan="7" style="text-align:center; color:#666;">No reviews found for this cleaning type.</td>
  </tr>
<%
}
%>

</table>

<%
        } // rs
    } catch (Exception e) {
      out.println("<p style='color:red'>Review list error: " + e.getMessage() + "</p>");
    }

} else {
%>
  <p class="note" style="margin-top:16px;">Please select a cleaning type to view reviews.</p>
<%
}
%>

</body>
</html>
