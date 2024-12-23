package kr.ac.dankook.MySQLProject.controller;

import kr.ac.dankook.MySQLProject.entity.Member;
import kr.ac.dankook.MySQLProject.service.MemberService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class MemberController {

    private final MemberService memberService;

    @GetMapping("/members/validate")
    public ResponseEntity<String> validateMembers() {
        memberService.validCheckAllMembers();
        return ResponseEntity.ok("Member validation process completed!");
    }

    @GetMapping("/members/invalid-report")
    public ResponseEntity<List<Member>> invalidReport() {
        return ResponseEntity.ok(memberService.getInvalidMemberReport());
    }

    @GetMapping("/member/{name}")
    public ResponseEntity<Member> getMember(@PathVariable String name) {
        Member member = memberService.getMemberByName(name);
        if (member != null){
            return ResponseEntity.ok(member);
        }
        return ResponseEntity.notFound().build();
    }
    
    @PostMapping("/member")
    public ResponseEntity<String> save(@RequestBody Member member){
        memberService.saveMember(member);
        return ResponseEntity.ok("Member saved!");
    }

    @DeleteMapping("/member/{name}")
    public ResponseEntity<String> delete(@PathVariable String name){
        if (memberService.deleteMember(name)){
            return ResponseEntity.ok("Member deleted!");
        }
        return ResponseEntity.ok("Member not found!");
    }

    @PatchMapping("/member/{name}")
    public ResponseEntity<String> updateMember(@PathVariable String name,@RequestBody Member newMember){
        Member member = memberService.updateMember(name,newMember);
        if (member != null){
            return ResponseEntity.ok("Member Updated!");
        }
        return ResponseEntity.ok("Member not found!");
    }

}
