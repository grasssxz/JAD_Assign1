<jsp:include page="/auth/AuthCheck.jsp" />
<%@ page trimDirectiveWhitespaces="true" %>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<style>
:root {
    --purple: #d4d6e0;
    --purple-border: #7f9cf5;
    --text-light: #ffffff;
}

/* NAVBAR */
.navbar {
    background: var(--purple);
    border-bottom: 2px solid var(--purple-border);
    padding: 16px 32px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    width: 100%;
    box-sizing: border-box;
}

/* LEFT + RIGHT GROUPS */
.nav-left, .nav-right {
    display: flex;
    align-items: center;
    gap: 28px;
}

/* LINKS */
.nav-link {
    color: var(--text-light);
    text-decoration: none;
    font-size: 15px;
    font-weight: 500;
    padding: 8px 14px;
    border-radius: 6px;
    transition: 0.25s;
}
.nav-link:hover {
    background: rgba(255,255,255,0.2);
}

/* BUTTONS */
.nav-btn {
    background: #7f9cf5 !important;
    padding: 8px 18px;
    border-radius: 6px;
    color: white !important;
    font-weight: 600;
    transition: 0.25s;
}
.nav-btn:hover {
    background: #6f8ce0 !important;
}

/* DROPDOWN */
.dropdown {
    position: relative;
}
.dropdown-menu {
    position: absolute;
    top: 110%;
    left: 0;
    background: white;
    min-width: 200px;
    padding: 10px 0;
    border-radius: 10px;
    display: none;
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
}
.dropdown:hover .dropdown-menu {
    display: block;
}
.dropdown-menu a {
    display: block;
    padding: 12px 18px;
    color: #333;
    text-decoration: none;
}
.dropdown-menu a:hover {
    background: #f2f2f2;
}

/* WELCOME */
.nav-welcome {
    color: white;
    font-weight: 500;
}
</style>

<%
    // SESSION VALUES
    Integer memberId = (Integer) session.getAttribute("member_id");
    String username  = (String) session.getAttribute("username");
    String role      = (String) session.getAttribute("type");

    boolean isGuest = (memberId == null);

    if (username == null) username = "Guest";
    if (role == null) role = "guest";
%>

<header class="navbar">

    <!-- LEFT SIDE -->
    <nav class="nav-left">

        <!-- WELCOME MESSAGE -->
        <span class="nav-welcome">
            Welcome, <%= (isGuest ? "Guest" : username) %>
        </span>

        <!-- HOME -->
        <a class="nav-link" href="<%= request.getContextPath() %>/home/HomePage.jsp">Home</a>

        <!-- CART (Only for logged-in users) -->
        <% if (!isGuest) { %>
            <a class="nav-link" href="<%= request.getContextPath() %>/Services/Caregiving/MealDelivery/ViewCart.jsp">Cart</a>
        <% } %>

        <!-- BOOKINGS DROPDOWN -->
        <% if (!isGuest) { %>
        <div class="dropdown">
            <a class="nav-link">Bookings ▼</a>
            <div class="dropdown-menu">
                <a class="hover:text-blue-600"
				       href="<%= request.getContextPath() %>/Services/Doctor/DoctorAppt/MyAppointments.jsp">
				       Doctor Online consult Bookings
				    </a>
                <a href="<%= request.getContextPath() %>/Services/Caregiving/Transportation/ViewTransportBookings.jsp">
				    Transportation Bookings
				</a>

                <a href="<%= request.getContextPath() %>/Services/Caregiving/Grocery/GroceryViewAppointments.jsp">
				    Grocery Bookings
				</a>

            </div>
        </div>
        <% } %>

        <!-- ADMIN PANEL -->
        <% if ("admin".equals(role)) { %>
            <a class="nav-link" href="<%= request.getContextPath() %>/admin/admin_homePage.html">Admin Panel</a>
        <% } %>

    </nav>

    <!-- RIGHT SIDE -->
    <nav class="nav-right">

        <% if (isGuest) { %>
            <!-- Guest -->
            <a class="nav-link nav-btn" href="<%= request.getContextPath() %>/login/login.html">Login</a>
            <a class="nav-link nav-btn" href="<%= request.getContextPath() %>/login/signUp.html">Sign Up</a>
        <% } else { %>
            <!-- Logged in -->
            <a class="nav-link nav-btn" href="<%= request.getContextPath() %>/login/logout.jsp">Logout</a>
        <% } %>

    </nav>

</header>
