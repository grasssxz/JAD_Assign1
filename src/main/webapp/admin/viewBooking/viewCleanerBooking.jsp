<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.sql.*" %>

<%
String connURL =
"jdbc:mysql://localhost:3306/jad_assign1"
+ "?user=root&password=1G9r5a6c1E**"
+ "&serverTimezone=UTC&useSSL=false&allowPublicKeyRetrieval=true";
Class.forName("com.mysql.cj.jdbc.Driver");

// session info
String role = (String) session.getAttribute("type");
Integer sessionMemberId = (Integer) session.getAttribute("member_id");

if (role == null) role = "guest";

// Block guests
if ("guest".equalsIgnoreCase(role) || sessionMemberId == null && !"admin".equalsIgnoreCase(role)) {
    response.sendRedirect(request.getContextPath() + "/login/login.html");
    return;
}

// parameters
String action = request.getParameter("action");
String deleteId = request.getParameter("id");
String searchMember = request.getParameter("member_id"); // admin optional search
String message = null;

/* ===============================
   DELETE BOOKING
   - member: only delete own booking
   - admin: delete any booking
================================*/
if ("delete".equals(action) && deleteId != null) {
    try (Connection connDel = DriverManager.getConnection(connURL)) {

        if ("admin".equalsIgnoreCase(role)) {
            PreparedStatement psDel = connDel.prepareStatement(
                "DELETE FROM cleaner_booking WHERE id=?"
            );
            psDel.setInt(1, Integer.parseInt(deleteId));
            psDel.executeUpdate();
            psDel.close();

        } else {
            PreparedStatement psDel = connDel.prepareStatement(
                "DELETE FROM cleaner_booking WHERE id=? AND member_id=?"
            );
            psDel.setInt(1, Integer.parseInt(deleteId));
            psDel.setInt(2, sessionMemberId);
            int rows = psDel.executeUpdate();
            psDel.close();

            if (rows == 0) {
                message = "You can only delete your own bookings.";
            }
        }

    } catch (Exception e) {
        message = "Delete failed: " + e.getMessage();
    }

    // redirect to clear repeat delete
    if ("admin".equalsIgnoreCase(role) && searchMember != null && !searchMember.trim().isEmpty()) {
        response.sendRedirect("viewCleanerBooking.jsp?member_id=" + searchMember.trim());
    } else {
        response.sendRedirect("viewCleanerBooking.jsp");
    }
    return;
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Cleaner Bookings</title>
<style>
body { font-family: Arial; padding: 20px; background:#f6f7fb; }
h2 { color:#4f46e5; margin-top:10px; }
table { border-collapse: collapse; width:100%; margin-top:16px; background:white; }
th, td { border:1px solid #ddd; padding:10px; vertical-align: top; }
th { background:#eef; }
.controls {
  margin-top: 12px; padding: 12px; background:#fff; border-radius:8px;
  display:flex; gap:12px; align-items:center; flex-wrap:wrap;
}
input[type=text] { padding:6px; width:180px; }
button {
  padding:6px 12px; background:#4f46e5; color:white;
  border:0; border-radius:6px; cursor:pointer;
}
.btn-del {
  background:#e11d48; color:white; padding:6px 10px;
  text-decoration:none; border-radius:6px; display:inline-block;
}
.btn-del:hover { background:#be123c; }
.back-btn {
  display:inline-block; padding:8px 14px; margin-bottom:8px;
  background:#64748b; color:white; text-decoration:none; border-radius:6px;
}
.msg { margin-top:10px; color:#b91c1c; font-weight:600; }
.note { color:#666; font-size:14px; }
.badge { padding:2px 8px; border-radius:10px; font-size:12px; color:white; }
.badge-paid { background:#16a34a; }
.badge-pending { background:#f59e0b; }
</style>
</head>
<body>

<% if ("admin".equalsIgnoreCase(role)) { %>
  <a href="<%=request.getContextPath()%>/admin/admin_homePage.jsp" class="back-btn">← Back to Admin Home</a>
<% } else { %>
  <a href="<%=request.getContextPath()%>/home/HomePage.jsp" class="back-btn">← Back to Home</a>
<% } %>

<h2><%= "admin".equalsIgnoreCase(role) ? "All Cleaner Bookings" : "My Cleaner Bookings" %></h2>

<% if (message != null) { %>
  <div class="msg"><%= message %></div>
<% } %>

<!-- ADMIN SEARCH -->
<% if ("admin".equalsIgnoreCase(role)) { %>
<form class="controls" method="get" action="viewCleanerBooking.jsp">
  <label><b>Search by Member ID:</b></label>
  <input type="text" name="member_id" value="<%= (searchMember!=null?searchMember:"") %>" placeholder="e.g. 5">
  <button type="submit">Search</button>
  <a class="note" href="viewCleanerBooking.jsp" style="margin-left:6px;">Clear Search</a>
</form>
<% } %>

<%
/* ===============================
   LIST BOOKINGS
================================*/
String sql =
  "SELECT b.id, b.member_id, b.cleaner_id, b.cleaning_type_id, b.hours, b.date, b.status, b.created_at, " +
  "       c.name AS cleaner_name, ct.name AS cleaning_type_name " +
  "FROM cleaner_booking b " +
  "JOIN cleaner c ON b.cleaner_id = c.id " +
  "JOIN cleaning_type ct ON b.cleaning_type_id = ct.id ";

boolean adminSearch = "admin".equalsIgnoreCase(role)
                      && searchMember != null
                      && !searchMember.trim().isEmpty();

if ("admin".equalsIgnoreCase(role)) {
    if (adminSearch) {
        sql += "WHERE b.member_id = ? ";
    }
} else {
    sql += "WHERE b.member_id = ? ";
}

sql += "ORDER BY b.created_at DESC";

try (Connection connList = DriverManager.getConnection(connURL);
     PreparedStatement ps = connList.prepareStatement(sql)) {

    if ("admin".equalsIgnoreCase(role)) {
        if (adminSearch) {
            ps.setInt(1, Integer.parseInt(searchMember.trim()));
        }
    } else {
        ps.setInt(1, sessionMemberId);
    }

    try (ResultSet rs = ps.executeQuery()) {
%>

<table>
  <tr>
    <th>ID</th>
    <th>Member ID</th>
    <th>Cleaner</th>
    <th>Cleaning Type</th>
    <th>Hours</th>
    <th>Date</th>
    <th>Status</th>
    <th>Booked At</th>
    <th>Action</th>
  </tr>

<%
boolean hasRows = false;
while (rs.next()) {
  hasRows = true;
%>
  <tr>
    <td><%= rs.getInt("id") %></td>
    <td><%= rs.getInt("member_id") %></td>
    <td><%= rs.getInt("cleaner_id") %> - <%= rs.getString("cleaner_name") %></td>
    <td><%= rs.getInt("cleaning_type_id") %> - <%= rs.getString("cleaning_type_name") %></td>
    <td><%= rs.getInt("hours") %></td>
    <td><%= rs.getDate("date") %></td>
    <td>
      <%
        String st = rs.getString("status");
        if ("paid".equalsIgnoreCase(st)) {
      %>
          <span class="badge badge-paid">paid</span>
      <%
        } else {
      %>
          <span class="badge badge-pending">pending</span>
      <%
        }
      %>
    </td>
    <td><%= rs.getTimestamp("created_at") %></td>
    <td>
      <a class="btn-del"
         onclick="return confirm('Delete this booking?');"
         href="viewCleanerBooking.jsp?action=delete&id=<%=rs.getInt("id")%><%= adminSearch ? "&member_id="+searchMember.trim() : "" %>">
         Delete
      </a>
    </td>
  </tr>
<%
}

if (!hasRows) {
%>
  <tr>
    <td colspan="9" style="text-align:center; color:#666;">
      No bookings found.
    </td>
  </tr>
<%
}
%>

</table>

<%
    }
} catch (Exception e) {
    out.println("<p style='color:red'>List error: " + e.getMessage() + "</p>");
}
%>

</body>
</html>
