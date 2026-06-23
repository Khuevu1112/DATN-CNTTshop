package com.fpoly.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

import com.fpoly.service.CustomUserDetailsService;

@Configuration
public class SecurityConfig {

    @Autowired
    private CustomUserDetailsService userDetailsService;

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http)
            throws Exception {

        http
            .csrf(csrf -> csrf.disable())

            .authorizeHttpRequests(auth -> auth

            		.requestMatchers(
            			    "/DustNovel/login",
            			    "/DustNovel/register",
            			    "/DustNovel/forgot-password",
            			    "/css/**",
            			    "/js/**",
            			    "/images/**"
            			).permitAll()

            	    .requestMatchers("/admin/users/**")
            	    .hasRole("ADMIN")

            	    .requestMatchers(
            	        "/admin/products/**",
            	        "/admin/categories/**"
            	    )
            	    .hasAnyRole("ADMIN","STAFF")

            	    .requestMatchers("/account/**")
            	    .hasAnyRole("ADMIN","STAFF","CUSTOMER")

            	    .anyRequest()
            	    .authenticated()
            	)

            .userDetailsService(userDetailsService)

            .formLogin(form -> form
                .loginPage("/DustNovel/login")
                .loginProcessingUrl("/DustNovel/login")
                .usernameParameter("username")
                .passwordParameter("password")
                .defaultSuccessUrl("/admin/dashboard", true)
                .failureUrl("/DustNovel/login?error=true")
                .permitAll()
            )

            .logout(logout -> logout
                .logoutUrl("/logout")
                .logoutSuccessUrl("/DustNovel/login?logout")
                .permitAll()
            );

        return http.build();
    }
}