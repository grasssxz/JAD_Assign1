<jsp:include page="/auth/RequireLogin.jsp" />
<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/home/NavBar.jsp" />
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<script src="https://cdn.tailwindcss.com"></script>

<%
    // ======================
    // GET SESSION USER
    // ======================
    Integer memberId = (Integer) session.getAttribute("member_id");

    if (memberId == null) {
%>
        <script>alert("Please log in first."); window.location.href="/login/login.html";</script>
<%
        return;
    }

    // ======================
    // READ FORM INPUT
    // ======================
    int providerId = Integer.parseInt(request.getParameter("provider_id"));
    String bookingDate = request.getParameter("booking_date");

    // ======================
    // CONNECT TO DB
    // ======================
    Class.forName("com.mysql.cj.jdbc.Driver");
    String url = "jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**";
    Connection conn = DriverManager.getConnection(url);

    // ======================
    // FETCH PROVIDER INFO
    // ======================
    PreparedStatement psProvider = conn.prepareStatement(
        "SELECT * FROM transport_provider WHERE id = ?"
    );
    psProvider.setInt(1, providerId);
    ResultSet provider = psProvider.executeQuery();
    provider.next();

    double baseFee = provider.getDouble("base_fee");
    
 // ======================
 // CHECK CLASHING BOOKINGS
 // ======================
 PreparedStatement psClash = conn.prepareStatement(
     "SELECT COUNT(*) AS cnt FROM transport_booking " +
     "WHERE member_id = ? AND booking_date = ? AND status != 'CANCELLED'"
 );
 psClash.setInt(1, memberId);
 psClash.setString(2, bookingDate);

 ResultSet clashRs = psClash.executeQuery();
 clashRs.next();
 int clashCount = clashRs.getInt("cnt");

 if (clashCount > 0) {
 %>
     <script>
         alert("You already have a transport booking on this date.");
         window.history.back();
     </script>
 <%
     return;
 }


    // ======================
    // INSERT BOOKING
    // ======================
    PreparedStatement psInsert = conn.prepareStatement(
        "INSERT INTO transport_booking (provider_id, member_id, booking_date, total_fee, status) " +
        "VALUES (?, ?, ?, ?, 'COMPLETED')",
        Statement.RETURN_GENERATED_KEYS
    );

    psInsert.setInt(1, providerId);
    psInsert.setInt(2, memberId);
    psInsert.setString(3, bookingDate);
    psInsert.setDouble(4, baseFee);

    psInsert.executeUpdate();

    // GET INSERTED BOOKING ID
    ResultSet generatedKeys = psInsert.getGeneratedKeys();
    int bookingId = 0;
    if (generatedKeys.next()) {
        bookingId = generatedKeys.getInt(1);
    }

    provider.close();
    psProvider.close();
    psInsert.close();
    conn.close();
%>

<!-- SUCCESS PAGE -->
<div class="min-h-screen flex items-center justify-center bg-gray-50">
    <div class="bg-white p-10 rounded-xl shadow-lg w-full max-w-lg text-center">

        <h1 class="text-3xl font-bold text-green-600 mb-6">Booking Confirmed!</h1>

        <div class="bg-gray-100 p-6 rounded-lg text-left">
            <p><b>Booking ID:</b> <%= bookingId %></p>
            <p><b>Provider:</b> <%= providerId %></p>
            <p><b>Selected Date:</b> <%= bookingDate %></p>
            <p><b>Total Fee:</b> $<%= baseFee %></p>
            <p><b>Status:</b> PENDING</p>
        </div>

        <a href="TransportList.jsp"
           class="mt-8 inline-block bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700">
            Return to Transport Providers
        </a>
    </div>
</div>
