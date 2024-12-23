package kr.ac.dankook.MySQLProject.entity;

import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;

import java.time.LocalDateTime;

public class MemberEntityListener {

    @PrePersist
    public void onPrePersist(Member member) {
        LocalDateTime now = LocalDateTime.now();
        member.setCreatedAt(now);
        member.setUpdatedAt(now);
    }

    @PreUpdate
    public void onPreUpdate(Member member) {
        member.setUpdatedAt(LocalDateTime.now());
    }
}
