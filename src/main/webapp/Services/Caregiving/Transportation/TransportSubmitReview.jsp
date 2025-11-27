<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");

    // ============================
    // 1. Retrieve form parameters
    // ============================
    String providerIdStr = request.getParameter("provider_id");
    String memberIdStr   = request.getParameter("member_id");
    String ratingStr     = request.getParameter("rating");
    String review        = request.getParameter("review");

    // Validate null / empty
    if (providerIdStr == null || memberIdStr == null || ratingStr == null || review == null ||
        providerIdStr.isEmpty() || memberIdStr.isEmpty() || ratingStr.isEmpty()) {
%>
<script>
alert("Invalid review submission. Missing fields.");
window.history.back();
</script>
<%
        return;
    }

    int providerId = Integer.parseInt(providerIdStr);
    int memberId   = Integer.parseInt(memberIdStr);
    int rating     = Integer.parseInt(ratingStr);


    // ============================
    // 2. Connect to database
    // ============================
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**"
    );


    // ============================
    // 3. Check if user has COMPLETED booking
    // ============================
    PreparedStatement ps = conn.prepareStatement(
        "SELECT id FROM transport_booking " +
        "WHERE provider_id=? AND member_id=? AND LOWER(status)='completed' " +
        "ORDER BY id DESC LIMIT 1"
    );
    ps.setInt(1, providerId);
    ps.setInt(2, memberId);
    ResultSet rs = ps.executeQuery();

    if (!rs.next()) {
        conn.close();
%>
<script>
alert("You can only review after completing a booking.");
window.history.back();
</script>
<%
        return;
    }

    int bookingId = rs.getInt("id");


    // ============================
    // 4. Check if review already exists
    // ============================
    PreparedStatement ps2 = conn.prepareStatement(
        "SELECT id FROM transport_review WHERE booking_id=? AND member_id=?"
    );
    ps2.setInt(1, bookingId);
    ps2.setInt(2, memberId);
    ResultSet rs2 = ps2.executeQuery();

    if (rs2.next()) {
        conn.close();
%>
<script>
alert("You have already submitted a review for this booking.");
window.history.back();
</script>
<%
        return;
    }


    // ============================
    // 5. Insert new review
    // ============================
    PreparedStatement insert = conn.prepareStatement(
        "INSERT INTO transport_review(provider_id, booking_id, member_id, rating, review, created_at) " +
        "VALUES (?, ?, ?, ?, ?, NOW())"
    );
    insert.setInt(1, providerId);
    insert.setInt(2, bookingId);
    insert.setInt(3, memberId);
    insert.setInt(4, rating);
    insert.setString(5, review);
    insert.executeUpdate();

    conn.close();
%>

<script>
alert("Review submitted successfully!");
window.location.href = "TransportDetails.jsp?id=<%=providerId%>";
</script>
