package kr.ac.dankook.MySQLProject.repository;

import kr.ac.dankook.MySQLProject.entity.Member;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.query.Procedure;

import java.util.List;
import java.util.Optional;

public interface MemberRepository  extends JpaRepository<Member, Long> {

    @Procedure(procedureName = "validate_member_data")
    void validateMemberData();
    @Procedure(procedureName = "generate_invalid_member_report")
    List<Member> generateInvalidMemberReport();
    Optional<Member> findByName(String name);
}