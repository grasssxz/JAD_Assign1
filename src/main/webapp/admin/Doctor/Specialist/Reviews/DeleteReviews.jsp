<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireAdmin.jsp" />

<%@ page import="java.sql.*" %>

<%
String id = request.getParameter("id");
if (id == null) {
    response.sendRedirect("ViewReviews.jsp?msg=Invalid review ID");
    return;
}

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
    "root","1G9r5a6c1E**"
);

// 1. Delete replies first (if table exists for future use)
try {
    PreparedStatement psRep = conn.prepareStatement(
        "DELETE FROM specialist_review_reply WHERE review_id=?"
    );
    psRep.setInt(1, Integer.parseInt(id));
    psRep.executeUpdate();
} catch (Exception e) {
    // ignore if table doesn't exist
}

// 2. Delete main review
PreparedStatement ps = conn.prepareStatement(
    "DELETE FROM specialist_review WHERE id=?"
);
ps.setInt(1, Integer.parseInt(id));
ps.executeUpdate();

conn.close();

response.sendRedirect("ViewReviews.jsp?msg=Review deleted successfully");
%>
