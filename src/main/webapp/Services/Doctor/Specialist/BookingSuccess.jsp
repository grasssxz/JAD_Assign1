<jsp:include page="/auth/AuthCheck.jsp" />
<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/RequireLogin.jsp" />

<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Appointment Confirmed</title>
<script src="https://cdn.tailwindcss.com"></script>
</head>

<body class="bg-gray-100">

<!-- NAV BAR -->
<jsp:include page="/home/NavBar.jsp" />

<%
String clinicName = request.getParameter("clinic");
String dateStr     = request.getParameter("date");
String timeStr     = request.getParameter("time");
String packageName = request.getParameter("package");
String priceStr    = request.getParameter("price");
%>

<div class="max-w-3xl mx-auto mt-12 bg-white p-8 rounded-xl shadow">

    <h1 class="text-3xl font-bold text-green-700 mb-6">
        Appointment Booked Successfully!
    </h1>

    <div class="space-y-4 text-lg text-gray-700">

        <p><b>Clinic:</b> <%= clinicName %></p>

        <p><b>Date:</b> <%= dateStr %></p>

        <p><b>Time:</b> <%= timeStr %></p>

        <p><b>Selected Package:</b> <%= packageName %></p>

        <p><b>Total Price:</b>
            <span class="text-green-600 font-semibold">
                $<%= priceStr %>
            </span>
        </p>

    </div>

    <div class="mt-10 flex gap-4">

        <a href="MyAppointments.jsp"
           class="px-6 py-3 bg-blue-600 text-white rounded-lg font-semibold hover:bg-blue-700">
           View My Appointments
        </a>

        <a href="<%= request.getContextPath() %>/Services/Doctor/Specialist/SpecialistClinicList.jsp"
           class="px-6 py-3 bg-gray-300 text-gray-700 rounded-lg font-semibold hover:bg-gray-400">
           Back to Clinics
        </a>

    </div>
</div>

</body>
</html>
