package com.fpoly.controller.api;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fpoly.dto.ContactDtos.ContactSubmitRequest;
import com.fpoly.service.ContactService;

/**
 * REST API công khai cho trang "Liên hệ" (User) — không cần đăng nhập.
 */
@RestController
@RequestMapping("/api/contact")
public class ContactApiController {

    @Autowired
    private ContactService contactService;

    @PostMapping
    public void submit(@RequestBody ContactSubmitRequest req) {
        contactService.submit(req);
    }
}
