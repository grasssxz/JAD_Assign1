<%@ page import="java.sql.*" %>

<jsp:include page="/auth/RequireLogin.jsp" />
<jsp:include page="/auth/SessisonInit.jsp" />

<%
    request.setCharacterEncoding("UTF-8");

    Integer memberId = (Integer) session.getAttribute("member_id");
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
    int cartItemId = Integer.parseInt(request.getParameter("cart_item_id"));
    int rating = Integer.parseInt(request.getParameter("rating"));
    String reviewText = request.getParameter("review_text");
    int providerId = Integer.parseInt(request.getParameter("provider_id"));

    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**"
    );

    // Validate ownership
    PreparedStatement psCheck = conn.prepareStatement(
        "SELECT * FROM reviews WHERE id=? AND member_id=?"
    );
    psCheck.setInt(1, reviewId);
    psCheck.setInt(2, memberId);
    ResultSet rsCheck = psCheck.executeQuery();

    if (!rsCheck.next()) {
        conn.close();
%>
        <script>
            alert("Invalid review update attempt.");
            window.location.href = "MealProviderDetails.jsp?id=<%= providerId %>";
        </script>
<%
        return;
    }

    // Update review
    PreparedStatement psUpdate = conn.prepareStatement(
        "UPDATE reviews SET cart_item_id=?, rating=?, review_text=? WHERE id=?"
    );
    psUpdate.setInt(1, cartItemId);
    psUpdate.setInt(2, rating);
    psUpdate.setString(3, reviewText);
    psUpdate.setInt(4, reviewId);

    psUpdate.executeUpdate();
    conn.close();
%>

<script>
    alert("Review updated successfully!");
    window.location.href = "MealProviderDetails.jsp?id=<%= providerId %>";
</script>
