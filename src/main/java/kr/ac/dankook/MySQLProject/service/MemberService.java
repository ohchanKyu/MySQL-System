package kr.ac.dankook.MySQLProject.service;

import kr.ac.dankook.MySQLProject.entity.Member;
import kr.ac.dankook.MySQLProject.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class MemberService {

    private final MemberRepository memberRepository;

    @Transactional
    public void validCheckAllMembers(){
        memberRepository.validateMemberData();
    }
    @Transactional
    public List<Member> getInvalidMemberReport(){
        return memberRepository.generateInvalidMemberReport();
    }
    @Transactional
    public void saveMember(Member newMember){
        memberRepository.save(newMember);
    }
    @Transactional
    public boolean deleteMember(String name){
        Optional<Member> targetMember = memberRepository.findByName(name);
        if (targetMember.isPresent()){
            memberRepository.deleteById(targetMember.get().getId());
            return true;
        }
        return false;
    }
    @Transactional
    public Member getMemberByName(String name){
        Optional<Member> targetMember = memberRepository.findByName(name);
        return targetMember.orElse(null);
    }
    @Transactional
    public Member updateMember(String name,Member newMember){
        Member oldMember = getMemberByName(name);
        if (oldMember != null){
            if (newMember.getName() != null){
                oldMember.setName(newMember.getName());
            }
            if (newMember.getEmail() != null){
                oldMember.setEmail(newMember.getEmail());
            }
            if (newMember.getPhoneNumber() != null){
                oldMember.setPhoneNumber(newMember.getPhoneNumber());
            }
            return memberRepository.save(oldMember);
        }
        return oldMember;
    }

}
