<jsp:include page="/auth/RequireLogin.jsp" />
<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/home/NavBar.jsp" />
<%@ page import="java.sql.*" %>

<%
    request.setCharacterEncoding("UTF-8");

    String reviewStr = request.getParameter("review_id");
    String providerStr = request.getParameter("provider_id");
    String reply = request.getParameter("reply_text");

    if (reviewStr == null || providerStr == null || reply == null) {
%>
<script>
alert("Missing information. Cannot submit reply.");
history.back();
</script>
<%
        return;
    }

    int reviewId = Integer.parseInt(reviewStr);
    int providerId = Integer.parseInt(providerStr);

    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**"
    );

    PreparedStatement ps = conn.prepareStatement(
        "INSERT INTO transport_reply (review_id, reply_text, created_at) VALUES (?, ?, NOW())"
    );
    ps.setInt(1, reviewId);
    ps.setString(2, reply);
    ps.executeUpdate();

    ps.close();
    conn.close();
%>

<script>
alert("Reply submitted.");
window.location.href = "TransportDetails.jsp?id=<%=providerId%>";
</script>
