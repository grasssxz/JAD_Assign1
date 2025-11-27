<jsp:include page="/auth/AuthCheck.jsp" />
<%@ page import="java.sql.*" %>

<%
Integer memberId = (Integer) session.getAttribute("member_id");
String role = (String) session.getAttribute("type");   // <-- ADD THIS

int reviewId = Integer.parseInt(request.getParameter("id"));

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**"
);

/* Get company_id and review owner */
PreparedStatement getComp = conn.prepareStatement(
    "SELECT company_id, member_id FROM grocery_review WHERE id=?"
);
getComp.setInt(1, reviewId);
ResultSet rs = getComp.executeQuery();

if (!rs.next()) {
%>
<script>alert("Review not found."); history.back();</script>
<%
    conn.close();
    return;
}

int companyId = rs.getInt("company_id");
int ownerId   = rs.getInt("member_id");

/*  OWNER OR ADMIN CAN DELETE */
if (ownerId != memberId && !"admin".equals(role)) {
%>
<script>alert("You can only delete your own review."); history.back();</script>
<%
    conn.close();
    return;
}

/* Delete review (cascade removes replies) */
PreparedStatement del = conn.prepareStatement(
    "DELETE FROM grocery_review WHERE id=?"
);
del.setInt(1, reviewId);
del.executeUpdate();

conn.close();
%>

<script>
alert("Review deleted.");
window.location.href = "GroceryDetails.jsp?id=<%= companyId %>";
</script>
