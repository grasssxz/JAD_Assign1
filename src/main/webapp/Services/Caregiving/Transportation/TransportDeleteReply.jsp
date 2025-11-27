<jsp:include page="/auth/RequireLogin.jsp" />
<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/home/NavBar.jsp" />
<%@ page import="java.sql.*" %>

<%
    request.setCharacterEncoding("UTF-8");

    String reviewStr = request.getParameter("review_id");
    String memberStr = request.getParameter("member_id");
    String providerStr = request.getParameter("provider_id");

    if (reviewStr == null || memberStr == null || providerStr == null) {
%>
<script>
alert("Error: Missing data for deletion.");
history.back();
</script>
<%
        return;
    }

    int reviewId = Integer.parseInt(reviewStr);
    int memberId = Integer.parseInt(memberStr);
    int providerId = Integer.parseInt(providerStr);

    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**"
    );

    PreparedStatement ps = conn.prepareStatement(
        "DELETE FROM transport_review WHERE id=? AND member_id=?"
    );
    ps.setInt(1, reviewId);
    ps.setInt(2, memberId);
    ps.executeUpdate();

    ps.close();
    conn.close();
%>

<script>
alert("Review deleted.");
window.location.href = "TransportDetails.jsp?id=<%=providerId%>";
</script>
