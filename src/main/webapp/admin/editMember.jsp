<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

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

String action      = request.getParameter("action");
String searchBy    = request.getParameter("searchBy");   // "id" or "username"
String searchValue = request.getParameter("searchValue");

String msg  = null;
String err  = null;

Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;

// Handle update status (enable/disable)
try {
    conn = DriverManager.getConnection(connURL);

    if ("updateStatus".equals(action) && "POST".equalsIgnoreCase(request.getMethod())) {
        String memberIdStr = request.getParameter("member_id");
        String status = request.getParameter("status"); // "1" or "0"

        if (memberIdStr != null && status != null) {
            int memberId = Integer.parseInt(memberIdStr);
            String isActive = status;

            PreparedStatement psUpd = conn.prepareStatement(
                "UPDATE member SET status = ? WHERE id = ?"
            );
            psUpd.setString(1, status);
            psUpd.setInt(2, memberId);

            int rows = psUpd.executeUpdate();
            if (rows > 0) {
                msg = "Member #" + memberId + " status updated successfully.";
            } else {
                err = "No member found with ID " + memberId + ".";
            }
            psUpd.close();
        } else {
            err = "Invalid member data for update.";
        }
    }

} catch (Exception e) {
    err = "Error updating member: " + e.getMessage();
} finally {
    // We will reopen the connection later for search to keep things simple
    if (conn != null) conn.close();
}

// Re-open a connection for search display
java.util.List<java.util.Map<String,Object>> results = new java.util.ArrayList<>();

try {
    conn = DriverManager.getConnection(connURL);

    if (searchBy != null && searchValue != null && !searchValue.trim().isEmpty()) {
        if ("id".equals(searchBy)) {
            ps = conn.prepareStatement("SELECT id, username, email, type, status FROM member WHERE id = ?");
            try {
                ps.setInt(1, Integer.parseInt(searchValue.trim()));
            } catch (NumberFormatException nfe) {
                err = "Please enter a valid numeric ID.";
            }
        } else if ("username".equals(searchBy)) {
            ps = conn.prepareStatement("SELECT id, username, email, type, status FROM member WHERE username LIKE ?");
            ps.setString(1, "%" + searchValue.trim() + "%");
        }

        if (ps != null && err == null) {
            rs = ps.executeQuery();
            while (rs.next()) {
                java.util.Map<String,Object> row = new java.util.HashMap<>();
                row.put("id",        rs.getInt("id"));
                row.put("username",  rs.getString("username"));
                row.put("email",     rs.getString("email"));
                row.put("type",      rs.getString("type"));
                row.put("status", rs.getString("status"));
                results.add(row);
            }
            if (results.isEmpty() && err == null) {
                msg = "No members found for given criteria.";
            }
        }
    }

} catch (Exception e) {
    err = "Error loading members: " + e.getMessage();
} finally {
    if (rs != null) rs.close();
    if (ps != null) ps.close();
    if (conn != null) conn.close();
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Edit Member Status</title>
<style>
  body { font-family: Arial, sans-serif; padding: 20px; background:#f8fafc; }
  h2 { margin-bottom: 10px; }
  .card { border:1px solid #ddd; padding:16px; border-radius:12px; margin-bottom: 16px; background:#ffffff; }
  .row { display:flex; gap:12px; margin-bottom:10px; align-items:center; }
  .row label { width:140px; font-weight:bold; }
  input[type="text"], select {
      padding:6px; 
      width:260px; 
      border:1px solid #cbd5e1; 
      border-radius:6px;
  }
  .btn { padding:6px 10px; border:0; cursor:pointer; text-decoration:none; display:inline-block; border-radius:6px; }
  .btn-search { background:#4f46e5; color:white; }
  .btn-update { background:#16a34a; color:white; }
  .btn-back { background:#64748b; color:white; margin-bottom:10px; }
  table { border-collapse: collapse; width: 100%; margin-top: 20px; background:#ffffff; }
  th, td { border: 1px solid #e5e7eb; padding: 8px; vertical-align: middle; }
  th { background: #f1f5f9; }
  .status-active { color:#16a34a; font-weight:bold; }
  .status-disabled { color:#dc2626; font-weight:bold; }
  .msg { background:#dcfce7; color:#166534; padding:8px 10px; border-radius:8px; margin-bottom:10px; }
  .err { background:#fee2e2; color:#991b1b; padding:8px 10px; border-radius:8px; margin-bottom:10px; }
</style>
</head>
<body>

<h2>Manage Member Status</h2>

<a class="btn btn-back" href="<%=request.getContextPath()%>/admin/admin_homePage.jsp">
  ← Back to Admin Home
</a>

<% if (msg != null) { %>
  <div class="msg"><%= msg %></div>
<% } %>
<% if (err != null) { %>
  <div class="err"><%= err %></div>
<% } %>

<div class="card">
  <h3>Search Member</h3>
  <form method="get" action="<%=request.getContextPath()%>/admin/editMember.jsp">
    <div class="row">
      <label>Search By</label>
      <select name="searchBy" required>
        <option value="">-- Choose --</option>
        <option value="id" <%= "id".equals(searchBy) ? "selected" : "" %>>Member ID</option>
        <option value="username" <%= "username".equals(searchBy) ? "selected" : "" %>>Username</option>
      </select>
    </div>

    <div class="row">
      <label>Search Value</label>
      <input type="text" name="searchValue" required value="<%= (searchValue == null ? "" : searchValue) %>" />
    </div>

    <button type="submit" class="btn btn-search">Search</button>
  </form>
</div>

<% if (!results.isEmpty()) { %>
  <div class="card">
    <h3>Search Results</h3>
    <table>
      <tr>
        <th>ID</th>
        <th>Username</th>
        <th>Email</th>
        <th>Type</th>
        <th>Status</th>
        <th>Update Status</th>
      </tr>

      <% for (java.util.Map<String,Object> row : results) {
     int mid = (Integer) row.get("id");
     String uname = (String) row.get("username");
     String email = (String) row.get("email");
     String type = (String) row.get("type");
     String statusVal = (String) row.get("status");   // renamed to avoid confusion
%>
<tr>
  <td><%= mid %></td>
  <td><%= uname %></td>
  <td><%= email %></td>
  <td><%= type %></td>
  <td>
    <% if ("activated".equals(statusVal)) { %>
      <span class="status-active">Active</span>
    <% } else { %>
      <span class="status-disabled">Disabled</span>
    <% } %>
  </td>
  <td>
    <form method="post"
          action="<%=request.getContextPath()%>/admin/editMember.jsp?action=updateStatus"
          style="display:inline-flex; gap:6px; align-items:center;">
      <input type="hidden" name="member_id" value="<%= mid %>" />
      <select name="status">
        <option value="activated"  <%= "activated".equals(statusVal)  ? "selected" : "" %>>Active</option>
        <option value="deactivated"<%= "deactivated".equals(statusVal) ? "selected" : "" %>>Disabled</option>
      </select>
      <button type="submit" class="btn btn-update">Save</button>
    </form>
  </td>
</tr>
<% } %>

    </table>
  </div>
<% } %>

</body>
</html>
