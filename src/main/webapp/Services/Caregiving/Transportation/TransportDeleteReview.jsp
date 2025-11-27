<jsp:include page="/auth/RequireLogin.jsp" />
<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/home/NavBar.jsp" />
<%@ page import="java.sql.*" %>

<%
    int reviewId = Integer.parseInt(request.getParameter("review_id"));
    int memberId = Integer.parseInt(request.getParameter("member_id"));

    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**");

    // Validate ownership
    PreparedStatement check = conn.prepareStatement(
        "SELECT provider_id FROM transport_review WHERE id=? AND member_id=?"
    );
    check.setInt(1, reviewId);
    check.setInt(2, memberId);
    ResultSet rs = check.executeQuery();

    if (!rs.next()) {
%>
<script>
alert("Unauthorized action.");
window.history.back();
</script>
<%
        return;
    }

    int providerId = rs.getInt("provider_id");

    conn.prepareStatement("DELETE FROM transport_reply WHERE review_id=" + reviewId).executeUpdate();
    conn.prepareStatement("DELETE FROM transport_review WHERE id=" + reviewId).executeUpdate();

    conn.close();
%>

<script>
alert("Review deleted.");
window.location.href="TransportDetails.jsp?id=<%=providerId%>";
</script>
