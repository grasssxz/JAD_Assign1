<%@ page import="java.sql.*" %>

<jsp:include page="/auth/RequireLogin.jsp" />
<jsp:include page="/auth/SessisonInit.jsp" />

<%
    request.setCharacterEncoding("UTF-8");

    Integer memberId = (Integer) session.getAttribute("member_id");
    String role = (String) session.getAttribute("role");

    if (memberId == null) {
%>
<script>
    alert("Please log in first.");
    window.location.href = "../../login/login.html";
</script>
<%
        return;
    }

    int reviewId = Integer.parseInt(request.getParameter("review_id"));
    int providerId = Integer.parseInt(request.getParameter("provider_id"));
    String replyText = request.getParameter("reply_text");

    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**"
    );

    PreparedStatement ps = conn.prepareStatement(
        "INSERT INTO review_reply (review_id, member_id, reply_text) VALUES (?, ?, ?)"
    );
    ps.setInt(1, reviewId);
    ps.setInt(2, memberId);
    ps.setString(3, replyText);

    ps.executeUpdate();
    conn.close();
%>

<script>
    alert("Reply posted!");
    window.location.href = "MealProviderDetails.jsp?id=<%= providerId %>";
</script>
