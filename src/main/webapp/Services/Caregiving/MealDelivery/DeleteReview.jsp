<%@ page import="java.sql.*" %>

<jsp:include page="/auth/RequireLogin.jsp" />
<jsp:include page="/auth/SessisonInit.jsp" />

<%
    Integer memberId = (Integer) session.getAttribute("member_id");
    String role = (String) session.getAttribute("role");

    if (memberId == null) {
%>
        <script>
            alert("Please log in.");
            window.location.href = "../../login/login.html";
        </script>
<%
        return;
    }

    int reviewId = Integer.parseInt(request.getParameter("id"));
    int providerId = Integer.parseInt(request.getParameter("provider"));

    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**"
    );

    // Fetch review to check ownership
    PreparedStatement psCheck = conn.prepareStatement(
        "SELECT member_id FROM reviews WHERE id=?"
    );
    psCheck.setInt(1, reviewId);
    ResultSet rs = psCheck.executeQuery();

    if (!rs.next()) {
        conn.close();
%>
        <script>
            alert("Review not found.");
            window.location.href = "MealProviderDetails.jsp?id=<%= providerId %>";
        </script>
<%
        return;
    }

    int reviewMemberId = rs.getInt("member_id");
    boolean canDelete = (reviewMemberId == memberId) || 
                        ("admin".equals(role));

    if (!canDelete) {
        conn.close();
%>
        <script>
            alert("You are not authorized to delete this review.");
            window.location.href = "MealProviderDetails.jsp?id=<%= providerId %>";
        </script>
<%
        return;
    }

    // Delete review
    PreparedStatement psDelete = conn.prepareStatement(
        "DELETE FROM reviews WHERE id=?"
    );
    psDelete.setInt(1, reviewId);
    psDelete.executeUpdate();

    conn.close();
%>

<script>
    alert("Review deleted successfully!");
    window.location.href = "MealProviderDetails.jsp?id=<%= providerId %>";
</script>
