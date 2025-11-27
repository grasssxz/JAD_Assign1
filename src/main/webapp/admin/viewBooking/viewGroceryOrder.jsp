<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.sql.*" %>

<%
String connURL =
"jdbc:mysql://localhost:3306/jad_assign1"
+ "?user=root&password=1G9r5a6c1E**"
+ "&serverTimezone=UTC&useSSL=false&allowPublicKeyRetrieval=true";
Class.forName("com.mysql.cj.jdbc.Driver");

String role = (String) session.getAttribute("type");
Integer sessionMemberId = (Integer) session.getAttribute("member_id");

if (role == null) role = "guest";

// prevent guests
if ("guest".equalsIgnoreCase(role) || (sessionMemberId == null && !"admin".equals(role))) {
    response.sendRedirect(request.getContextPath() + "/login/login.html");
    return;
}

String action = request.getParameter("action");
String cancelId = request.getParameter("id");
String searchMember = request.getParameter("member_id");
String message = null;

/* ===============================
   CANCEL ORDER
================================*/
if ("cancel".equals(action) && cancelId != null) {
    try (Connection conn = DriverManager.getConnection(connURL)) {

        if ("admin".equalsIgnoreCase(role)) {
            PreparedStatement ps = conn.prepareStatement(
                "UPDATE grocery_order SET status='CANCELLED' WHERE id=?"
            );
            ps.setInt(1, Integer.parseInt(cancelId));
            ps.executeUpdate();
            ps.close();
        } else {
            PreparedStatement ps = conn.prepareStatement(
                "UPDATE grocery_order SET status='CANCELLED' WHERE id=? AND member_id=?"
            );
            ps.setInt(1, Integer.parseInt(cancelId));
            ps.setInt(2, sessionMemberId);
            int rows = ps.executeUpdate();
            ps.close();

            if (rows == 0) message = "You can only cancel your own orders.";
        }

    } catch (Exception e) {
        message = "Cancel error: " + e.getMessage();
    }

    // Refresh
    if ("admin".equals(role) && searchMember != null && !searchMember.trim().isEmpty()) {
        response.sendRedirect("viewGroceryOrder.jsp?member_id=" + searchMember.trim());
    } else {
        response.sendRedirect("viewGroceryOrder.jsp");
    }
    return;
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Grocery Orders</title>

<style>
body { font-family: Arial; padding: 20px; background: #f6f7fb; }
h2 { color:#4f46e5; }

table { width: 100%; border-collapse: collapse; margin-top: 16px; background:#fff; }
th, td { padding: 10px; border:1px solid #ddd; }
th { background:#eef; }

.controls {
  margin-top:12px; background:#fff; padding:12px;
  border-radius:8px; display:flex; gap:12px; align-items:center;
}

input[type=text] { padding:6px; width:180px; }
button { padding:6px 12px; background:#4f46e5; color:white; border:0; border-radius:6px; cursor:pointer;}
.back-btn {
  display:inline-block; padding:8px 14px; margin-bottom:8px;
  background:#64748b; color:white; text-decoration:none; border-radius:6px;
}

.btn-cancel {
  background:#e11d48; color:white; padding:6px 10px;
  border-radius:6px; text-decoration:none;
}
.btn-cancel:hover { background:#be123c; }

.msg { color:#b91c1c; font-weight:600; }

.badge { padding:3px 8px; border-radius:12px; color:white; font-size:12px; }
.badge-pending { background:#f59e0b; }
.badge-confirmed { background:#3b82f6; }
.badge-cancelled { background:#dc2626; }
.badge-delivered { background:#16a34a; }

.note { color:#666; font-size:14px; }
</style>
</head>

<body>

<% if ("admin".equals(role)) { %>
    <a href="<%=request.getContextPath()%>/admin/admin_homePage.jsp" class="back-btn">← Back to Admin Home</a>
<% } else { %>
    <a href="<%=request.getContextPath()%>/home/HomePage.jsp" class="back-btn">← Back to Home</a>
<% } %>

<h2><%= "admin".equals(role) ? "All Grocery Orders" : "My Grocery Orders" %></h2>



<!-- ADMIN SEARCH FILTER -->
<% if ("admin".equals(role)) { %>
<form class="controls" method="get" action="viewGroceryOrder.jsp">
  <label><b>Search Member ID:</b></label>
  <input type="text" name="member_id"
         value="<%= searchMember != null ? searchMember : "" %>"
         placeholder="e.g. 5">
  <button type="submit">Search</button>
  <a href="viewGroceryOrder.jsp" class="note">Clear</a>
</form>
<% } %>

<%
/* ===============================
   LOAD ORDERS
================================*/
String sql =
  "SELECT go.id, go.member_id, go.company_id, go.order_datetime, go.total_price, go.status, " +
  "       gc.name AS company_name " +
  "FROM grocery_order go " +
  "JOIN grocery_company gc ON go.company_id = gc.id ";

boolean adminSearch = "admin".equals(role) &&
                      searchMember != null && !searchMember.trim().isEmpty();

if ("admin".equals(role)) {
    if (adminSearch) sql += "WHERE go.member_id=? ";
} else {
    sql += "WHERE go.member_id=? ";
}

sql += "ORDER BY go.order_datetime DESC";

try (Connection conn = DriverManager.getConnection(connURL);
     PreparedStatement ps = conn.prepareStatement(sql)) {

    if ("admin".equals(role)) {
        if (adminSearch) {
            ps.setInt(1, Integer.parseInt(searchMember.trim()));
        }
    } else {
        ps.setInt(1, sessionMemberId);
    }

    ResultSet rs = ps.executeQuery();
%>

<table>
<tr>
  <th>ID</th>
  <th>Member ID</th>
  <th>Company</th>
  <th>Order Time</th>
  <th>Total Price</th>
  <th>Status</th>
  <th>Action</th>
</tr>

<%
boolean hasRows = false;

while (rs.next()) {
    hasRows = true;
    String st = rs.getString("status");
%>

<tr>
  <td><%= rs.getInt("id") %></td>
  <td><%= rs.getInt("member_id") %></td>
  <td><%= rs.getInt("company_id") %> - <%= rs.getString("company_name") %></td>
  <td><%= rs.getTimestamp("order_datetime") %></td>
  <td>$<%= rs.getBigDecimal("total_price") %></td>

  <td>
    <% if ("PENDING".equalsIgnoreCase(st)) { %>
        <span class="badge badge-pending">pending</span>
    <% } else if ("CONFIRMED".equalsIgnoreCase(st)) { %>
        <span class="badge badge-confirmed">confirmed</span>
    <% } else if ("CANCELLED".equalsIgnoreCase(st)) { %>
        <span class="badge badge-cancelled">cancelled</span>
    <% } else { %>
        <span class="badge badge-delivered">delivered</span>
    <% } %>
  </td>

  <td>
    <% if (!"CANCELLED".equalsIgnoreCase(st)) { %>
    <a class="btn-cancel"
       onclick="return confirm('Cancel this order?');"
       href="viewGroceryOrder.jsp?action=cancel&id=<%=rs.getInt("id")%><%= adminSearch ? "&member_id=" + searchMember.trim() : "" %>">
        Cancel
    </a>
    <% } %>
  </td>
</tr>

<%
}
if (!hasRows) {
%>
<tr>
  <td colspan="7" style="text-align:center; color:#666;">No grocery orders found.</td>
</tr>
<%
}
%>

</table>

<%
} catch (Exception e) {
    out.println("<p style='color:red'>Error loading orders: " + e.getMessage() + "</p>");
}
%>

</body>
</html>
