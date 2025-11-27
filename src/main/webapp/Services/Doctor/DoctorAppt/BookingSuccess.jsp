<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireLogin.jsp" />

<%@ page import="java.sql.*" %>
<%
request.setCharacterEncoding("UTF-8");

/* Read info from redirect URL */
String doctorName = request.getParameter("doctor");
String date = request.getParameter("date");
String time = request.getParameter("time");
String packageName = request.getParameter("package");
String finalPrice = request.getParameter("price");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<title>Booking Successful</title>
<script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100">

<div class="max-w-xl mx-auto mt-20 p-8 bg-white shadow-lg rounded-xl text-center">

    <h1 class="text-3xl font-bold text-green-600 mb-4">
        Appointment Successfully Booked!
    </h1>

    <p class="text-gray-700 mb-6">
        Thank you. Your appointment has been confirmed.
    </p>

    <div class="text-left space-y-2 bg-gray-50 p-5 rounded-lg border">
        <p><b>Doctor:</b> <%= doctorName %></p>
        <p><b>Date:</b> <%= date %></p>
        <p><b>Time:</b> <%= time %></p>
        <p><b>Package:</b> <%= packageName %></p>
        <p><b>Final Price:</b> $<%= finalPrice %></p>
    </div>

    <div class="mt-6 space-y-3">
        <a href="DoctorList.jsp"
           class="block w-full bg-blue-600 text-white px-4 py-3 rounded-lg hover:bg-blue-700">
           Back to Doctor List
        </a>

        <a href="MyAppointments.jsp"
           class="block w-full bg-gray-200 px-4 py-3 rounded-lg hover:bg-gray-300">
           View My Appointments
        </a>
    </div>

</div>

</body>
</html>
