<jsp:include page="/auth/SessisonInit.jsp" />

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">

<head>
<meta charset="UTF-8">
<title>Find a Specialist Clinic</title>
<script src="https://cdn.tailwindcss.com"></script>
</head>

<body class="bg-gray-100">

<!-- NAV BAR -->
<div id="navbar-container"></div>
<script>
fetch("<%= request.getContextPath() %>/home/NavBar.jsp")
  .then(res => res.text())
  .then(html => document.getElementById("navbar-container").innerHTML = html);
</script>

<section class="max-w-7xl mx-auto px-6 py-10">
    <h1 class="text-4xl font-bold text-gray-900 mb-10">Find a Specialist Clinic</h1>

    <!-- GRID -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-10">

        <%
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/jad_assign1?serverTimezone=UTC",
            "root",
            "1G9r5a6c1E**"
        );

        PreparedStatement ps = conn.prepareStatement("SELECT * FROM specialist_clinic");
        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
        %>

        <!-- CARD -->
        <div class="bg-white rounded-3xl shadow-lg hover:shadow-2xl transition-all duration-300 
                    border border-gray-100 p-7 h-full flex flex-col min-h-[380px]">

            <!-- TOP CONTENT -->
            <div class="flex-1">
                <!-- TITLE -->
                <h2 class="text-2xl font-bold text-gray-900 mb-3">
                    <%= rs.getString("name") %>
                </h2>

                <!-- DESCRIPTION -->
                <p class="text-gray-700 text-sm leading-relaxed mb-6">
                    <%= rs.getString("description") %>
                </p>

                <!-- ADDRESS -->
                <div class="flex items-start gap-3 mb-3">
                    <svg class="w-5 h-5 text-blue-600 mt-0.5" fill="none" stroke="currentColor" stroke-width="2"
                        viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round"
                            d="M17.657 16.657L13.414 20.9a1.8 1.8 0 01-2.828 0l-4.243-4.243a8 8 0 111.414-1.414L10.586 6.1a1.8 1.8 0 012.828 0l4.243 4.243a8 8 0 010 6.314z" />
                    </svg>
                    <p class="text-gray-800 text-sm">
                        <b>Address:</b> <%= rs.getString("address") %>
                    </p>
                </div>

                <!-- PHONE -->
                <div class="flex items-start gap-3 mb-6">
                    <svg class="w-5 h-5 text-blue-600 mt-0.5" fill="none" stroke="currentColor" stroke-width="2"
                        viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round"
                            d="M3 5a2 2 0 012-2h2.28a2 2 0 011.933 1.515l.497 1.986a2 2 0 01-.54 1.95l-1.27 1.27a16 16 0 007.586 7.586l1.27-1.27a2 2 0 011.95-.54l1.986.497A2 2 0 0121 18.72V21a2 2 0 01-2 2 19 19 0 01-19-19z" />
                    </svg>
                    <p class="text-gray-800 text-sm">
                        <b>Phone:</b> <%= rs.getString("phone") %>
                    </p>
                </div>
            </div>

            <!-- BUTTON -->
            <a href="SpecialistDetails.jsp?id=<%= rs.getInt("id") %>"
               class="block bg-blue-600 hover:bg-blue-700 transition-all duration-200 text-white
                      text-center py-3 rounded-xl font-semibold shadow-md">
                View Clinic
            </a>
        </div>

        <% } conn.close(); %>

    </div>
</section>

</body>
</html>
