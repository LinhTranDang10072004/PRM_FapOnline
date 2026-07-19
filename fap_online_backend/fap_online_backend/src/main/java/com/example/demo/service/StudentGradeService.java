package com.example.demo.service;

import com.example.demo.dto.GradeItemDTO;
import com.example.demo.entity.ClassGradeComponent;
import com.example.demo.entity.ClassStudent;
import com.example.demo.entity.StudentGrade;
import com.example.demo.repository.ClassGradeComponentRepository;
import com.example.demo.repository.ClassStudentRepository;
import com.example.demo.repository.StudentGradeRepository;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class StudentGradeService {


    private final StudentGradeRepository studentGradeRepository;

    private final ClassGradeComponentRepository classGradeComponentRepository;

    private final ClassStudentRepository classStudentRepository;



    public StudentGradeService(
            StudentGradeRepository studentGradeRepository,
            ClassGradeComponentRepository classGradeComponentRepository,
            ClassStudentRepository classStudentRepository
    ) {

        this.studentGradeRepository = studentGradeRepository;
        this.classGradeComponentRepository = classGradeComponentRepository;
        this.classStudentRepository = classStudentRepository;

    }



    // ==========================================
    // TEACHER VIEW GRADE
    // ==========================================


    public List<GradeItemDTO> getGradeItemsByClassId(
            Integer classId,
            Integer teacherId
    ) {


        List<GradeItemDTO> grades =
                studentGradeRepository
                        .getGradeItemsByClassId(classId);

        System.out.println("Class = " + classId);
        System.out.println("Teacher = " + teacherId);
        System.out.println("Grade size = " + grades.size());

        // Nếu lớp chưa có bảng điểm
        if(grades.isEmpty()) {


            createEmptyGrades(
                    classId,
                    teacherId
            );


            grades =
                    studentGradeRepository
                            .getGradeItemsByClassId(classId);
            System.out.println("After create = " + grades.size());

        }



        return grades;

    }





    // ==========================================
    // CREATE EMPTY GRADE TABLE
    // ==========================================


    private void createEmptyGrades(
            Integer classId,
            Integer teacherId
    ) {



        List<ClassStudent> students =
                classStudentRepository
                        .findByClassId(classId);



        List<ClassGradeComponent> components =
                classGradeComponentRepository
                        .findByClassId(classId);




        for(ClassStudent student : students) {


            for(ClassGradeComponent component : components) {



                StudentGrade oldGrade =
                        studentGradeRepository
                                .findByStudentIdAndClassGradeComponentIdAndClassId(
                                        student.getStudentId(),
                                        component.getClassGradeComponentId(),
                                        classId
                                );



                // đã có rồi thì bỏ qua
                if(oldGrade != null) {
                    continue;
                }




                StudentGrade grade =
                        new StudentGrade();



                grade.setClassId(classId);



                grade.setStudentId(
                        student.getStudentId()
                );



                grade.setClassGradeComponentId(
                        component.getClassGradeComponentId()
                );



                // chưa nhập điểm
                grade.setScore(null);



                grade.setStatus(
                        "Draft"
                );



                grade.setEnteredByTeacherId(
                        teacherId
                );



                grade.setEnteredAt(
                        LocalDateTime.now()
                );



                studentGradeRepository.save(grade);


            }

        }


    }






    // ==========================================
    // STUDENT VIEW GRADE
    // ==========================================


    public List<StudentGrade> getGradesByStudentId(
            Integer studentId
    ) {


        return studentGradeRepository
                .findByStudentId(studentId);

    }







    // ==========================================
    // CREATE / UPDATE GRADE
    // ==========================================


    public StudentGrade saveGrade(
            StudentGrade grade
    ) {



        // Validate điểm

        if(grade.getScore() != null) {


            if(
                    grade.getScore()
                            .compareTo(BigDecimal.ZERO) < 0

                            ||

                            grade.getScore()
                                    .compareTo(BigDecimal.TEN) > 0
            ) {


                throw new RuntimeException(
                        "Score must be between 0 and 10"
                );

            }

        }





        // Create

        if(grade.getStudentGradeId() == null) {


            grade.setEnteredAt(
                    LocalDateTime.now()
            );


            grade.setStatus(
                    "Draft"
            );


        }



        // Update

        else {


            grade.setUpdatedAt(
                    LocalDateTime.now()
            );


        }




        return studentGradeRepository.save(grade);

    }







    // ==========================================
    // DELETE
    // ==========================================


    public void deleteGrade(
            Integer id
    ) {


        studentGradeRepository.deleteById(id);

    }







    // ==========================================
    // FIND BY ID
    // ==========================================


    public StudentGrade getGradeById(
            Integer id
    ) {


        return studentGradeRepository
                .findById(id)
                .orElseThrow(() ->
                        new RuntimeException(
                                "Grade not found"
                        )
                );

    }


}